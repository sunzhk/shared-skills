"""Complex Python module with nested indentation."""

from typing import Optional, List, Dict
import os
import sys


class UserService:
    """Service for managing user operations."""

    def __init__(self, db_connection: str, config: Optional[Dict] = None):
        self.db = db_connection
        self.config = config or {}
        self.cache: Dict[str, User] = {}

    def get_user(self, user_id: int) -> Optional[User]:
        """Retrieve a user by their ID.

        Args:
            user_id: The unique identifier for the user.

        Returns:
            The User object if found, None otherwise.
        """
        if user_id in self.cache:
            return self.cache[user_id]

        for user in self._query_users():
            if user.id == user_id:
                self.cache[user_id] = user
                return user

        return None

    def create_user(self, name: str, email: str) -> User:
        """Create a new user in the system."""
        user = User(id=self._next_id(), name=name, email=email)
        self._save_user(user)
        return user


class ProductService:
    """Service for managing product operations."""

    def __init__(self, db_connection: str):
        self.db = db_connection
        self.cache: Dict[str, Product] = {}

    def get_product(self, product_id: int) -> Optional[Product]:
        """Retrieve a product by its ID."""
        if product_id in self.cache:
            return self.cache[product_id]

        for product in self._query_products():
            if product.id == product_id:
                self.cache[product_id] = product
                return product

        return None


class User:
    def __init__(self, id: int, name: str, email: str):
        self.id = id
        self.name = name
        self.email = email


class Product:
    def __init__(self, id: int, name: str, price: float):
        self.id = id
        self.name = name
        self.price = price
