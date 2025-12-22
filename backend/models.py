from sqlalchemy import Column, Integer, String, DateTime, Boolean, Float, ForeignKey, Text, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

# Association table for many-to-many relationship between articles and orders
order_items = Table(
    'order_items',
    Base.metadata,
    Column('id', Integer, primary_key=True),
    Column('order_id', Integer, ForeignKey('orders.id')),
    Column('article_id', Integer, ForeignKey('articles.id')),
    Column('quantity', Integer, default=1),
    Column('price_at_purchase', Float),  # Store price at time of purchase
    Column('size', String(20), nullable=True),
    Column('color', String(50), nullable=True),
)

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)  # For shop owner
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    orders = relationship("Order", back_populates="user")
    wishlist_items = relationship("WishlistItem", back_populates="user")
    cart_items = relationship("CartItem", back_populates="user")


class Category(Base):
    __tablename__ = "categories"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False, index=True)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    articles = relationship("Article", back_populates="category")


class Article(Base):
    __tablename__ = "articles"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False, index=True)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    brand = Column(String(100), nullable=True)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    
    # Product details
    image_url = Column(String(500), nullable=True)
    stock_quantity = Column(Integer, default=0)
    is_featured = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    
    # Discount and ratings
    discount_percentage = Column(Float, default=0.0)  # 0-100
    rating = Column(Float, default=0.0)  # 0-5
    review_count = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    category = relationship("Category", back_populates="articles")
    wishlist_items = relationship("WishlistItem", back_populates="article")
    cart_items = relationship("CartItem", back_populates="article")


class Order(Base):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Order details
    total_amount = Column(Float, nullable=False)
    status = Column(String(50), default="pending")  # pending, confirmed, shipped, delivered, cancelled
    
    # Shipping details
    shipping_address = Column(Text, nullable=True)
    shipping_city = Column(String(100), nullable=True)
    shipping_postal_code = Column(String(20), nullable=True)
    shipping_country = Column(String(100), nullable=True)
    
    # Payment
    payment_method = Column(String(50), nullable=True)  # card, cash, paypal, etc.
    payment_status = Column(String(50), default="unpaid")  # unpaid, paid, refunded
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    shipped_at = Column(DateTime, nullable=True)
    delivered_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="orders")


class WishlistItem(Base):
    __tablename__ = "wishlist_items"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    article_id = Column(Integer, ForeignKey("articles.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="wishlist_items")
    article = relationship("Article", back_populates="wishlist_items")


class CartItem(Base):
    __tablename__ = "cart_items"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    article_id = Column(Integer, ForeignKey("articles.id"), nullable=False)
    quantity = Column(Integer, default=1)
    size = Column(String(20), nullable=True)
    color = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="cart_items")
    article = relationship("Article", back_populates="cart_items")