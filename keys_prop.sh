#!/bin/bash

# Read all variables from root .env file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^#.*$ ]] && continue
    
    # Extract variable name and value
    var_name=$(echo "$line" | cut -d'=' -f1)
    var_value=$(echo "$line" | cut -d'=' -f2-)
    
    # For each module, copy the .env.example and add the variable
    for i in {1..6}; do
        # Check if studio directory exists
        if [ -d "module-$i/studio" ]; then
            # Create .env file from .env.example if it doesn't exist
            if [ ! -f "module-$i/studio/.env" ]; then
                if [ -f "module-$i/studio/.env.example" ]; then
                    cp "module-$i/studio/.env.example" "module-$i/studio/.env"
                else
                    touch "module-$i/studio/.env"
                fi
            fi
            
            # Add or update the variable in the module's .env file
            if grep -q "^$var_name=" "module-$i/studio/.env"; then
                # Variable exists, update it
                sed -i '' "s|^$var_name=.*|$var_name=$var_value|" "module-$i/studio/.env"
            else
                # Variable doesn't exist, append it
                echo "$var_name=$var_value" >> "module-$i/studio/.env"
            fi
        else
            echo "Warning: module-$i/studio directory does not exist"
        fi
    done
done < .env