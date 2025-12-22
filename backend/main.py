from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List, Optional
from database import get_db, create_tables
from models import User, Article, Category, CartItem, WishlistItem
from schemas import (
    UserCreate, UserLogin, UserResponse, Token,
    ArticleResponse, CategoryResponse,
    CartItemCreate, CartItemUpdate, CartItemResponse, CartSummary,
    WishlistItemCreate, WishlistItemResponse
)
from auth import verify_password, get_password_hash, create_access_token, verify_token

# Create tables on startup
create_tables()

app = FastAPI(title="MaBoutique API", version="1.0.0", description="API for MaBoutique Shop")

security = HTTPBearer()

# Helper function to get current user
def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    token = credentials.credentials
    username = verify_token(token)
    
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

# ============================================
# ROOT ENDPOINT
# ============================================

@app.get("/")
def root():
    return {"message": "Welcome to MaBoutique API!", "status": "running"}

# ============================================
# AUTH ENDPOINTS
# ============================================

@app.post("/auth/signup", response_model=Token)
def signup(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(User).filter(
        (User.email == user_data.email) | (User.username == user_data.username)
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email or username already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=hashed_password,
        full_name=user_data.full_name,
        phone=user_data.phone
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Create access token
    access_token = create_access_token(data={"sub": user_data.username})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": UserResponse.from_orm(db_user)
    }

@app.post("/auth/login", response_model=Token)
def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    # Find user
    user = db.query(User).filter(User.username == user_credentials.username).first()
    
    if not user or not verify_password(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    # Create access token
    access_token = create_access_token(data={"sub": user.username})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": UserResponse.from_orm(user)
    }

@app.get("/auth/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    return UserResponse.from_orm(current_user)

@app.get("/auth/test")
def test_auth(current_user: User = Depends(get_current_user)):
    return {"message": f"Hello {current_user.username}! You are authenticated."}


# ============================================
# CATEGORY ENDPOINTS
# ============================================

@app.get("/categories", response_model=List[CategoryResponse])
def get_categories(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all active categories"""
    categories = db.query(Category).filter(Category.is_active == True).offset(skip).limit(limit).all()
    return categories


@app.get("/categories/{category_id}", response_model=CategoryResponse)
def get_category(category_id: int, db: Session = Depends(get_db)):
    """Get a single category by ID"""
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category


# ============================================
# ARTICLE ENDPOINTS
# ⚠️ IMPORTANT: Specific routes MUST come BEFORE parameterized routes
# ============================================

@app.get("/articles/featured", response_model=List[ArticleResponse])
def get_featured_articles(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """Get featured articles"""
    articles = db.query(Article).filter(
        Article.is_featured == True,
        Article.is_active == True
    ).offset(skip).limit(limit).all()
    return articles


@app.get("/articles/on-sale", response_model=List[ArticleResponse])
def get_sale_articles(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """Get articles with discounts"""
    articles = db.query(Article).filter(
        Article.discount_percentage > 0,
        Article.is_active == True
    ).offset(skip).limit(limit).all()
    return articles


@app.get("/articles/search", response_model=List[ArticleResponse])
def search_articles(
    q: str = Query(..., min_length=1),
    category_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """Search articles by name or description"""
    query = db.query(Article).filter(Article.is_active == True)
    
    # Search in name and description
    search_filter = Article.name.ilike(f"%{q}%") | Article.description.ilike(f"%{q}%")
    query = query.filter(search_filter)
    
    if category_id:
        query = query.filter(Article.category_id == category_id)
    
    articles = query.offset(skip).limit(limit).all()
    return articles


@app.get("/articles", response_model=List[ArticleResponse])
def get_articles(
    category_id: Optional[int] = Query(None),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all articles, optionally filtered by category"""
    query = db.query(Article).filter(Article.is_active == True)
    
    if category_id:
        query = query.filter(Article.category_id == category_id)
    
    articles = query.offset(skip).limit(limit).all()
    return articles


@app.get("/articles/{article_id}", response_model=ArticleResponse)
def get_article(article_id: int, db: Session = Depends(get_db)):
    """Get a single article by ID"""
    article = db.query(Article).filter(Article.id == article_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    return article


# ============================================
# CART ENDPOINTS
# ============================================

@app.get("/cart", response_model=CartSummary)
def get_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's cart with summary"""
    cart_items = db.query(CartItem).filter(CartItem.user_id == current_user.id).all()
    
    total_items = sum(item.quantity for item in cart_items)
    subtotal = 0.0
    total_discount = 0.0
    
    for item in cart_items:
        item_price = item.article.price * item.quantity
        subtotal += item_price
        
        if item.article.discount_percentage > 0:
            discount = item_price * (item.article.discount_percentage / 100)
            total_discount += discount
    
    total = subtotal - total_discount
    
    return {
        "total_items": total_items,
        "subtotal": subtotal,
        "total_discount": total_discount,
        "total": total,
        "items": cart_items
    }


@app.post("/cart", response_model=CartItemResponse)
def add_to_cart(
    item_data: CartItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add item to cart"""
    # Check if article exists
    article = db.query(Article).filter(Article.id == item_data.article_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    
    # Check if item already in cart
    existing_item = db.query(CartItem).filter(
        CartItem.user_id == current_user.id,
        CartItem.article_id == item_data.article_id,
        CartItem.size == item_data.size,
        CartItem.color == item_data.color
    ).first()
    
    if existing_item:
        # Update quantity
        existing_item.quantity += item_data.quantity
        db.commit()
        db.refresh(existing_item)
        return existing_item
    
    # Create new cart item
    cart_item = CartItem(
        user_id=current_user.id,
        article_id=item_data.article_id,
        quantity=item_data.quantity,
        size=item_data.size,
        color=item_data.color
    )
    
    db.add(cart_item)
    db.commit()
    db.refresh(cart_item)
    
    return cart_item


@app.put("/cart/{cart_item_id}", response_model=CartItemResponse)
def update_cart_item(
    cart_item_id: int,
    item_update: CartItemUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update cart item quantity or details"""
    cart_item = db.query(CartItem).filter(
        CartItem.id == cart_item_id,
        CartItem.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    if item_update.quantity is not None:
        if item_update.quantity <= 0:
            db.delete(cart_item)
            db.commit()
            return {"message": "Item removed from cart"}
        cart_item.quantity = item_update.quantity
    
    if item_update.size is not None:
        cart_item.size = item_update.size
    
    if item_update.color is not None:
        cart_item.color = item_update.color
    
    db.commit()
    db.refresh(cart_item)
    
    return cart_item


@app.delete("/cart/{cart_item_id}")
def remove_from_cart(
    cart_item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove item from cart"""
    cart_item = db.query(CartItem).filter(
        CartItem.id == cart_item_id,
        CartItem.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    db.delete(cart_item)
    db.commit()
    
    return {"message": "Item removed from cart"}


@app.delete("/cart")
def clear_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Clear entire cart"""
    db.query(CartItem).filter(CartItem.user_id == current_user.id).delete()
    db.commit()
    
    return {"message": "Cart cleared"}


# ============================================
# WISHLIST ENDPOINTS
# ============================================

@app.get("/wishlist", response_model=List[WishlistItemResponse])
def get_wishlist(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's wishlist"""
    wishlist_items = db.query(WishlistItem).filter(
        WishlistItem.user_id == current_user.id
    ).all()
    
    return wishlist_items


@app.post("/wishlist", response_model=WishlistItemResponse)
def add_to_wishlist(
    item_data: WishlistItemCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add item to wishlist"""
    # Check if article exists
    article = db.query(Article).filter(Article.id == item_data.article_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    
    # Check if already in wishlist
    existing_item = db.query(WishlistItem).filter(
        WishlistItem.user_id == current_user.id,
        WishlistItem.article_id == item_data.article_id
    ).first()
    
    if existing_item:
        raise HTTPException(status_code=400, detail="Item already in wishlist")
    
    # Create wishlist item
    wishlist_item = WishlistItem(
        user_id=current_user.id,
        article_id=item_data.article_id
    )
    
    db.add(wishlist_item)
    db.commit()
    db.refresh(wishlist_item)
    
    return wishlist_item


@app.delete("/wishlist/{article_id}")
def remove_from_wishlist(
    article_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove item from wishlist"""
    wishlist_item = db.query(WishlistItem).filter(
        WishlistItem.user_id == current_user.id,
        WishlistItem.article_id == article_id
    ).first()
    
    if not wishlist_item:
        raise HTTPException(status_code=404, detail="Item not in wishlist")
    
    db.delete(wishlist_item)
    db.commit()
    
    return {"message": "Item removed from wishlist"}


@app.delete("/wishlist")
def clear_wishlist(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Clear entire wishlist"""
    db.query(WishlistItem).filter(WishlistItem.user_id == current_user.id).delete()
    db.commit()
    
    return {"message": "Wishlist cleared"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)