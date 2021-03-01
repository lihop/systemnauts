if [ ! -f .venv/bin/activate ] || ! source .venv/bin/activate; then python -m venv .venv && source .venv/bin/activate; fi
if ! gdformat --version; then pip install -r requirements.txt; fi
if [ -z $1 ]; then find game/ -type f -name "*.gd" | xargs gdformat; else gdformat $1; fi
