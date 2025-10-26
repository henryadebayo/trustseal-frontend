#!/bin/bash

echo "🔍 Verifying all API requests use the correct base URL..."
echo ""

# Check for localhost references
echo "1. Checking for localhost references..."
LOCALHOST_COUNT=$(grep -r "localhost" lib/ 2>/dev/null | grep -v "node_modules" | wc -l | tr -d ' ')
if [ "$LOCALHOST_COUNT" -eq 0 ]; then
  echo "   ✅ No localhost references found"
else
  echo "   ❌ Found $LOCALHOST_COUNT localhost references:"
  grep -r "localhost" lib/ 2>/dev/null | grep -v "node_modules"
fi

# Check for old backend URLs
echo ""
echo "2. Checking for old backend URLs..."
OLD_URL_COUNT=$(grep -r "http://localhost:3000" lib/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$OLD_URL_COUNT" -eq 0 ]; then
  echo "   ✅ No old localhost URLs found"
else
  echo "   ❌ Found $OLD_URL_COUNT old URLs:"
  grep -r "http://localhost:3000" lib/
fi

# Check for new backend URL
echo ""
echo "3. Checking for new backend URL..."
NEW_URL_COUNT=$(grep -r "hackerton-8it2.onrender.com" lib/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$NEW_URL_COUNT" -gt 0 ]; then
  echo "   ✅ Found $NEW_URL_COUNT references to new backend:"
  grep -r "hackerton-8it2.onrender.com" lib/ 2>/dev/null
else
  echo "   ❌ No references to new backend found"
fi

# Check base URL in ApiService
echo ""
echo "4. Checking ApiService base URL..."
API_SERVICE_URL=$(grep -A 1 "static const String baseUrl" lib/core/services/api_service.dart 2>/dev/null | grep "hackerton")
if [ ! -z "$API_SERVICE_URL" ]; then
  echo "   ✅ ApiService using correct URL: $API_SERVICE_URL"
else
  echo "   ❌ ApiService not using correct URL"
fi

# Check VaultService base URL
echo ""
echo "5. Checking VaultService base URL..."
VAULT_SERVICE_URL=$(grep -A 1 "static const String _baseUrl" lib/core/services/vault_service.dart 2>/dev/null | grep "hackerton")
if [ ! -z "$VAULT_SERVICE_URL" ]; then
  echo "   ✅ VaultService using correct URL: $VAULT_SERVICE_URL"
else
  echo "   ❌ VaultService not using correct URL"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$LOCALHOST_COUNT" -eq 0 ] && [ "$OLD_URL_COUNT" -eq 0 ] && [ "$NEW_URL_COUNT" -gt 0 ]; then
  echo "✅ VERIFICATION PASSED: All requests use the new base URL"
else
  echo "❌ VERIFICATION FAILED: Issues found"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

