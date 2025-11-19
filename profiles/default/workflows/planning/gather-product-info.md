Collect comprehensive product information from the user:

```bash
# Check if product folder already exists
if [ -d "qa-agent-os/product" ]; then
    echo "Product documentation already exists. Review existing files or start fresh?"
    # List existing product files
    ls -la qa-agent-os/product/
fi
```

Gather from user the following required information:
- **Product Idea**: Core concept and purpose (required)
- **Key Features**: Minimum 3 features with descriptions
- **Target Users**: At least 1 user segment with use cases

If any required information is missing, prompt user:
```
Please provide the following to create your product plan:
1. Main idea for the product
2. List of key features (minimum 3)
3. Target users and use cases (minimum 1)
```
