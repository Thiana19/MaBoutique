from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

# ============================================
# USER SCHEMAS
# ============================================

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: Optional[str] = None
    phone: Optional[str] = None

class UserLogin(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: Optional[str]
    phone: Optional[str]
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class TokenData(BaseModel):
    username: Optional[str] = None


# ============================================
# CATEGORY SCHEMAS
# ============================================

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# ============================================
# ARTICLE SCHEMAS
# ============================================

class ArticleBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    brand: Optional[str] = None
    category_id: int
    image_url: Optional[str] = None
    stock_quantity: int = 0
    is_featured: bool = False
    discount_percentage: float = 0.0

class ArticleCreate(ArticleBase):
    pass

class ArticleResponse(ArticleBase):
    id: int
    is_active: bool
    rating: float
    review_count: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# ============================================
# CART SCHEMAS
# ============================================

class CartItemCreate(BaseModel):
    article_id: int
    quantity: int = 1
    size: Optional[str] = None
    color: Optional[str] = None

class CartItemUpdate(BaseModel):
    quantity: Optional[int] = None
    size: Optional[str] = None
    color: Optional[str] = None

class CartItemResponse(BaseModel):
    id: int
    user_id: int
    article_id: int
    quantity: int
    size: Optional[str]
    color: Optional[str]
    created_at: datetime
    updated_at: datetime
    article: ArticleResponse
    
    class Config:
        from_attributes = True

class CartSummary(BaseModel):
    total_items: int
    subtotal: float
    total_discount: float
    total: float
    items: list[CartItemResponse]


# ============================================
# WISHLIST SCHEMAS
# ============================================

class WishlistItemCreate(BaseModel):
    article_id: int

class WishlistItemResponse(BaseModel):
    id: int
    user_id: int
    article_id: int
    created_at: datetime
    article: ArticleResponse
    
    class Config:
        from_attributes = True