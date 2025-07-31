#!/usr/bin/env python3

import os
import sys
import subprocess

# Check if running in Docker (non-interactive environment)
IN_DOCKER = os.environ.get('PYTHONUNBUFFERED', '') == '1' or os.path.exists('/.dockerenv')

# Check if running in a virtual environment
if not hasattr(sys, 'real_prefix') and not (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
    print("⚠️  Warning: It's recommended to run this script in a virtual environment.")
    print("   You can set up and activate one with:")
    print("   python3 -m venv env && source env/bin/activate")
    
    # Skip interactive prompt if running in Docker
    if IN_DOCKER:
        print("Detected Docker environment, continuing automatically...")
        response = 'y'
    else:
        response = input("Continue anyway? (y/n): ")
        
    if response.lower() != 'y':
        print("Exiting. Please activate the virtual environment and try again.")
        sys.exit(1)

# Try to import transformers, install if missing
try:
    from transformers import AutoModelForSequenceClassification, AutoTokenizer
except ImportError:
    print("⚠️  transformers package not found. Installing...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "transformers", "torch"])
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

# Create models directory if it doesn't exist
try:
    os.makedirs("models/hf/bart-large-mnli", exist_ok=True)
    os.makedirs("models/hf/roberta-rejection", exist_ok=True)
    print("✅ Created model directories")
except Exception as e:
    print(f"❌ Error creating model directories: {e}")
    sys.exit(1)

# ⚙️ Force download and specify custom cache directory
print("\n📥 Downloading models. This may take several minutes...")

try:
    print("\n📥 Downloading BART for zero-shot classification...")
    AutoTokenizer.from_pretrained(
        "facebook/bart-large-mnli", 
        cache_dir="models/hf/bart-large-mnli",
        local_files_only=False,
        force_download=True
    )
    AutoModelForSequenceClassification.from_pretrained(
        "facebook/bart-large-mnli", 
        cache_dir="models/hf/bart-large-mnli",
        local_files_only=False,
        force_download=True
    )

    print("\n📥 Downloading RoBERTa for rejection classification...")
    AutoTokenizer.from_pretrained(
        "ynie/roberta-large-snli_mnli_fever_anli_R1_R2_R3-nli", 
        cache_dir="models/hf/roberta-rejection",
        local_files_only=False,
        force_download=True
    )
    AutoModelForSequenceClassification.from_pretrained(
        "ynie/roberta-large-snli_mnli_fever_anli_R1_R2_R3-nli", 
        cache_dir="models/hf/roberta-rejection",
        local_files_only=False,
        force_download=True
    )

    print("\n✅ All models downloaded successfully to ./models")
    print("🚀 You can now run the API with: ./start_api.sh")
except Exception as e:
    print(f"\n❌ Error downloading models: {e}")
    sys.exit(1)
