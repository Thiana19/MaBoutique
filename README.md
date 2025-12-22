# MaBoutique – Full-Stack E-Commerce Platform 🛍️

A professional-grade boutique application featuring a robust **FastAPI** backend and a sleek **Flutter** mobile frontend. This project demonstrates a complete end-to-end implementation of an e-commerce ecosystem, including secure authentication, relational database management, and reactive state management.



## 📱 Mobile Experience

The MaBoutique app features a unified design system with high-fidelity UI that adapts seamlessly to user preferences.

### Core Shopping Interface
| Home Screen (Dark) | Home Screen (Light) | Wishlist |
| :---: | :---: | :---: |
| <img src="screenshots/home_dark.png" width="250"> | <img src="screenshots/home_white.png" width="250"> | <img src="screenshots/wishlist_dark.png" width="250"> |

### Authentication & User Profile
| Login | Signup | Profile Page |
| :---: | :---: | :---: |
| <img src="screenshots/login_dark.png" width="250"> | <img src="screenshots/signup_white.png" width="250"> | <img src="screenshots/profile_dark.png" width="250"> |

### Cart & Branding
| Shopping Bag | Forgot Password | Splash Screen |
| :---: | :---: | :---: |
| <img src="screenshots/cart_dark.png" width="250"> | <img src="screenshots/forgot_password_white.png" width="250"> | <img src="screenshots/splash_white.png" width="250"> |

---

## 🛠️ Technical Deep-Dive

### **Backend (Python / FastAPI)**
* **Secure Auth:** Implemented **JWT (JSON Web Token)** authentication with **HTTPBearer** and password hashing via Bcrypt.
* **Relational Database:** Designed a schema with **SQLAlchemy ORM** to manage relationships between Users, Categories, Articles, and Carts.
* **Dynamic Pricing:** Developed server-side logic for real-time cart summaries, including subtotaling and automated discount calculations.
* **Search Engine:** Built endpoints for advanced product filtering by category, name, or description.

### **Frontend (Dart / Flutter)**
* **State Management:** Leveraged the **Provider** package for persistent, reactive updates to the shopping cart and wishlist states.
* **Theming:** Fully implemented Light and Dark modes with custom assets and `flutter_native_splash` integration.
* **Persistence:** Used `shared_preferences` for session management and local user data storage.

---

## 📂 Project Structure
```text
MaBoutique/
├── backend/       # FastAPI source code, database models, and auth logic
├── frontend/      # Flutter mobile application source code
└── screenshots/   # UI/UX previews for Dark and Light themes
