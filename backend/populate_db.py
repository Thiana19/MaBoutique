"""
Database Population Script for MaBoutique
Populates 10 articles for each category: Clothes, Shoes, Accessories
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import random

# Import your models (adjust the import path as needed)
from models import Base, Article, Category  # Adjust based on your models.py structure

# Database configuration
DATABASE_URL = "sqlite:///maboutique.db"  # Adjust to your database URL

# Create engine and session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Sample data for articles
CLOTHES_ARTICLES = [
    {
        "name": "Classic White T-Shirt",
        "description": "Essential cotton t-shirt perfect for everyday wear",
        "price": 19.99,
        "image_url": "https://via.placeholder.com/300x400/FFFFFF/000000?text=White+T-Shirt",
        "brand": "BasicWear",
        "sizes": ["XS", "S", "M", "L", "XL"],
        "colors": ["White", "Black", "Gray"],
    },
    {
        "name": "Slim Fit Jeans",
        "description": "Modern slim fit denim jeans with stretch comfort",
        "price": 59.99,
        "image_url": "https://via.placeholder.com/300x400/1E3A8A/FFFFFF?text=Slim+Jeans",
        "brand": "DenimCo",
        "sizes": ["28", "30", "32", "34", "36"],
        "colors": ["Dark Blue", "Light Blue", "Black"],
    },
    {
        "name": "Wool Blend Sweater",
        "description": "Cozy wool blend sweater for cold weather",
        "price": 79.99,
        "image_url": "https://via.placeholder.com/300x400/7C3AED/FFFFFF?text=Wool+Sweater",
        "brand": "WarmKnits",
        "sizes": ["S", "M", "L", "XL"],
        "colors": ["Navy", "Burgundy", "Charcoal"],
    },
    {
        "name": "Leather Jacket",
        "description": "Premium genuine leather jacket with classic styling",
        "price": 299.99,
        "image_url": "https://via.placeholder.com/300x400/000000/FFFFFF?text=Leather+Jacket",
        "brand": "UrbanEdge",
        "sizes": ["S", "M", "L", "XL"],
        "colors": ["Black", "Brown"],
    },
    {
        "name": "Cotton Chinos",
        "description": "Versatile cotton chinos for smart casual looks",
        "price": 49.99,
        "image_url": "https://via.placeholder.com/300x400/D97706/FFFFFF?text=Chinos",
        "brand": "SmartWear",
        "sizes": ["30", "32", "34", "36", "38"],
        "colors": ["Khaki", "Navy", "Olive"],
    },
    {
        "name": "Hooded Sweatshirt",
        "description": "Comfortable pullover hoodie with kangaroo pocket",
        "price": 44.99,
        "image_url": "https://via.placeholder.com/300x400/6B7280/FFFFFF?text=Hoodie",
        "brand": "StreetStyle",
        "sizes": ["S", "M", "L", "XL", "XXL"],
        "colors": ["Gray", "Black", "Navy"],
    },
    {
        "name": "Dress Shirt",
        "description": "Crisp dress shirt perfect for formal occasions",
        "price": 54.99,
        "image_url": "https://via.placeholder.com/300x400/3B82F6/FFFFFF?text=Dress+Shirt",
        "brand": "FormalFit",
        "sizes": ["14.5", "15", "15.5", "16", "16.5"],
        "colors": ["White", "Light Blue", "Pink"],
    },
    {
        "name": "Cargo Pants",
        "description": "Utility cargo pants with multiple pockets",
        "price": 64.99,
        "image_url": "https://via.placeholder.com/300x400/065F46/FFFFFF?text=Cargo+Pants",
        "brand": "OutdoorGear",
        "sizes": ["30", "32", "34", "36"],
        "colors": ["Olive", "Black", "Tan"],
    },
    {
        "name": "Polo Shirt",
        "description": "Classic polo shirt with ribbed collar and cuffs",
        "price": 34.99,
        "image_url": "https://via.placeholder.com/300x400/DC2626/FFFFFF?text=Polo+Shirt",
        "brand": "SportStyle",
        "sizes": ["S", "M", "L", "XL"],
        "colors": ["Red", "Navy", "White"],
    },
    {
        "name": "Winter Parka",
        "description": "Insulated winter parka with fur-trimmed hood",
        "price": 199.99,
        "image_url": "https://via.placeholder.com/300x400/1F2937/FFFFFF?text=Winter+Parka",
        "brand": "ArcticWear",
        "sizes": ["M", "L", "XL", "XXL"],
        "colors": ["Black", "Navy", "Forest Green"],
    }
]

SHOES_ARTICLES = [
    {
        "name": "Running Sneakers",
        "description": "Lightweight running shoes with cushioned sole",
        "price": 89.99,
        "image_url": "https://via.placeholder.com/300x400/EF4444/FFFFFF?text=Running+Shoes",
        "brand": "SpeedRun",
        "sizes": ["7", "8", "9", "10", "11", "12"],
        "colors": ["Red/White", "Blue/Black", "Gray"],
    },
    {
        "name": "Leather Oxford",
        "description": "Classic leather oxford shoes for formal wear",
        "price": 129.99,
        "image_url": "https://via.placeholder.com/300x400/78350F/FFFFFF?text=Oxford+Shoes",
        "brand": "ClassicShoe",
        "sizes": ["7", "8", "9", "10", "11"],
        "colors": ["Black", "Brown", "Tan"],
    },
    {
        "name": "Canvas Sneakers",
        "description": "Casual canvas sneakers for everyday comfort",
        "price": 49.99,
        "image_url": "https://via.placeholder.com/300x400/10B981/FFFFFF?text=Canvas+Sneakers",
        "brand": "UrbanStep",
        "sizes": ["6", "7", "8", "9", "10", "11"],
        "colors": ["White", "Navy", "Black"],
    },
    {
        "name": "Hiking Boots",
        "description": "Waterproof hiking boots with ankle support",
        "price": 139.99,
        "image_url": "https://via.placeholder.com/300x400/92400E/FFFFFF?text=Hiking+Boots",
        "brand": "TrailMaster",
        "sizes": ["8", "9", "10", "11", "12"],
        "colors": ["Brown", "Black"],
    },
    {
        "name": "Slip-On Loafers",
        "description": "Easy slip-on loafers for casual elegance",
        "price": 79.99,
        "image_url": "https://via.placeholder.com/300x400/1E40AF/FFFFFF?text=Loafers",
        "brand": "ComfortWalk",
        "sizes": ["7", "8", "9", "10", "11"],
        "colors": ["Navy", "Brown", "Black"],
    },
    {
        "name": "Basketball Shoes",
        "description": "High-top basketball shoes with ankle support",
        "price": 119.99,
        "image_url": "https://via.placeholder.com/300x400/F59E0B/FFFFFF?text=Basketball+Shoes",
        "brand": "HoopStar",
        "sizes": ["8", "9", "10", "11", "12", "13"],
        "colors": ["Black/Gold", "White/Red", "Blue"],
    },
    {
        "name": "Sandals",
        "description": "Comfortable summer sandals with adjustable straps",
        "price": 39.99,
        "image_url": "https://via.placeholder.com/300x400/14B8A6/FFFFFF?text=Sandals",
        "brand": "BeachWalk",
        "sizes": ["7", "8", "9", "10", "11"],
        "colors": ["Black", "Brown", "Tan"],
    },
    {
        "name": "Chelsea Boots",
        "description": "Stylish Chelsea boots with elastic side panels",
        "price": 149.99,
        "image_url": "https://via.placeholder.com/300x400/451A03/FFFFFF?text=Chelsea+Boots",
        "brand": "BootCraft",
        "sizes": ["7", "8", "9", "10", "11"],
        "colors": ["Black", "Brown", "Tan"],
    },
    {
        "name": "Training Shoes",
        "description": "Cross-training shoes for gym workouts",
        "price": 94.99,
        "image_url": "https://via.placeholder.com/300x400/7C3AED/FFFFFF?text=Training+Shoes",
        "brand": "FitGear",
        "sizes": ["7", "8", "9", "10", "11", "12"],
        "colors": ["Black", "Gray/Blue", "Red"],
    },
    {
        "name": "Dress Boots",
        "description": "Polished dress boots for formal occasions",
        "price": 169.99,
        "image_url": "https://via.placeholder.com/300x400/000000/FFFFFF?text=Dress+Boots",
        "brand": "Elegance",
        "sizes": ["7", "8", "9", "10", "11"],
        "colors": ["Black", "Dark Brown"],
    }
]

ACCESSORIES_ARTICLES = [
    {
        "name": "Leather Belt",
        "description": "Genuine leather belt with metal buckle",
        "price": 29.99,
        "image_url": "https://via.placeholder.com/300x400/78350F/FFFFFF?text=Leather+Belt",
        "brand": "BeltMaster",
        "sizes": ["32", "34", "36", "38", "40"],
        "colors": ["Black", "Brown", "Tan"],
    },
    {
        "name": "Wool Scarf",
        "description": "Soft wool scarf for winter warmth",
        "price": 34.99,
        "image_url": "https://via.placeholder.com/300x400/DC2626/FFFFFF?text=Wool+Scarf",
        "brand": "WarmAccessories",
        "sizes": ["One Size"],
        "colors": ["Red", "Navy", "Gray", "Black"],
    },
    {
        "name": "Baseball Cap",
        "description": "Classic baseball cap with adjustable strap",
        "price": 24.99,
        "image_url": "https://via.placeholder.com/300x400/1E3A8A/FFFFFF?text=Baseball+Cap",
        "brand": "CapStyle",
        "sizes": ["One Size"],
        "colors": ["Black", "Navy", "Red", "Gray"],
    },
    {
        "name": "Leather Wallet",
        "description": "Bifold leather wallet with multiple card slots",
        "price": 44.99,
        "image_url": "https://via.placeholder.com/300x400/000000/FFFFFF?text=Wallet",
        "brand": "LeatherWorks",
        "sizes": ["One Size"],
        "colors": ["Black", "Brown"],
    },
    {
        "name": "Sunglasses",
        "description": "UV protection sunglasses with polarized lenses",
        "price": 89.99,
        "image_url": "https://via.placeholder.com/300x400/1F2937/FFFFFF?text=Sunglasses",
        "brand": "SunShield",
        "sizes": ["One Size"],
        "colors": ["Black", "Brown", "Silver"],
    },
    {
        "name": "Wristwatch",
        "description": "Analog wristwatch with leather strap",
        "price": 149.99,
        "image_url": "https://via.placeholder.com/300x400/92400E/FFFFFF?text=Watch",
        "brand": "TimePiece",
        "sizes": ["One Size"],
        "colors": ["Silver/Black", "Gold/Brown", "Black"],
    },
    {
        "name": "Backpack",
        "description": "Durable backpack with laptop compartment",
        "price": 69.99,
        "image_url": "https://via.placeholder.com/300x400/374151/FFFFFF?text=Backpack",
        "brand": "CarryAll",
        "sizes": ["One Size"],
        "colors": ["Black", "Navy", "Gray"],
    },
    {
        "name": "Leather Gloves",
        "description": "Lined leather gloves for winter",
        "price": 39.99,
        "image_url": "https://via.placeholder.com/300x400/451A03/FFFFFF?text=Gloves",
        "brand": "WarmHands",
        "sizes": ["S", "M", "L", "XL"],
        "colors": ["Black", "Brown"],
    },
    {
        "name": "Tie",
        "description": "Silk tie for formal occasions",
        "price": 29.99,
        "image_url": "https://via.placeholder.com/300x400/1E40AF/FFFFFF?text=Silk+Tie",
        "brand": "FormalWear",
        "sizes": ["One Size"],
        "colors": ["Navy", "Red", "Black", "Silver"],
    },
    {
        "name": "Beanie Hat",
        "description": "Knit beanie for cold weather",
        "price": 19.99,
        "image_url": "https://via.placeholder.com/300x400/6B7280/FFFFFF?text=Beanie",
        "brand": "KnitWear",
        "sizes": ["One Size"],
        "colors": ["Black", "Gray", "Navy", "Red"],
    }
]

def create_categories():
    """Create the three main categories"""
    categories = []
    category_names = ["Clothes", "Shoes", "Accessories"]
    
    for name in category_names:
        # Check if category already exists
        existing = session.query(Category).filter_by(name=name).first()
        if not existing:
            category = Category(
                name=name,
                description=f"Browse our collection of {name.lower()}",
                image_url=f"https://via.placeholder.com/400x300/3B82F6/FFFFFF?text={name}"
            )
            session.add(category)
            categories.append(category)
        else:
            categories.append(existing)
    
    session.commit()
    return categories

def create_articles(category, articles_data):
    """Create articles for a given category"""
    created_articles = []
    
    for data in articles_data:
        article = Article(
            name=data["name"],
            description=data["description"],
            price=data["price"],
            image_url=data["image_url"],
            brand=data["brand"],
            category_id=category.id,
            stock_quantity=random.randint(10, 100),
            is_featured=random.choice([True, False]),
            discount_percentage=random.choice([0, 10, 15, 20, 25]),
            rating=round(random.uniform(3.5, 5.0), 1),
            created_at=datetime.utcnow()
        )
        
        session.add(article)
        created_articles.append(article)
    
    session.commit()
    return created_articles

def populate_database():
    """Main function to populate the database"""
    print("🚀 Starting database population...")
    
    # Create tables if they don't exist
    Base.metadata.create_all(engine)
    
    # Create categories
    print("\n📁 Creating categories...")
    categories = create_categories()
    clothes_cat, shoes_cat, accessories_cat = categories
    print(f"✅ Created/Found {len(categories)} categories")
    
    # Create articles for each category
    print("\n👕 Creating Clothes articles...")
    clothes_articles = create_articles(clothes_cat, CLOTHES_ARTICLES)
    print(f"✅ Created {len(clothes_articles)} clothes articles")
    
    print("\n👟 Creating Shoes articles...")
    shoes_articles = create_articles(shoes_cat, SHOES_ARTICLES)
    print(f"✅ Created {len(shoes_articles)} shoes articles")
    
    print("\n🎒 Creating Accessories articles...")
    accessories_articles = create_articles(accessories_cat, ACCESSORIES_ARTICLES)
    print(f"✅ Created {len(accessories_articles)} accessories articles")
    
    print(f"\n🎉 Database population complete!")
    print(f"📊 Total articles created: {len(clothes_articles) + len(shoes_articles) + len(accessories_articles)}")
    
    session.close()

if __name__ == "__main__":
    try:
        populate_database()
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        session.rollback()
        session.close()