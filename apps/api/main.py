import sys
import os

# Add the apps/api directory to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

from api.index import app

# Vercel expects 'app' or 'handler'
