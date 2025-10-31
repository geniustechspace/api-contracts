#!/bin/bash
# =============================================================================
# Common Types Module Validation Script
# =============================================================================
# Validates the modular organization of common types for:
# - Module structure and file existence
# - Package naming consistency
# - Documentation coverage
# - Compliance annotations
# - Import dependencies
# - Message naming conventions
#
# Usage: ./scripts/validate_modules.sh
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to print colored output
print_status() {
    if [ "$1" == "PASS" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((CHECKS_PASSED++))
    elif [ "$1" == "FAIL" ]; then
        echo -e "${RED}✗${NC} $2"
        ((CHECKS_FAILED++))
    elif [ "$1" == "INFO" ]; then
        echo -e "${BLUE}ℹ${NC} $2"
    elif [ "$1" == "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $2"
    fi
}

echo "========================================="
echo "Common Types Module Validation"
echo "========================================="
echo ""

# =============================================================================
# 1. MODULE STRUCTURE VALIDATION
# =============================================================================

echo "1. Validating Module Structure..."
echo "-----------------------------------"

COMMON_DIR="proto/common"
EXPECTED_MODULES=(
    "enums.proto"
    "base.proto"
    "metadata.proto"
    "geography.proto"
    "pagination.proto"
    "auth.proto"
    "context.proto"
    "money.proto"
    "time.proto"
    "files.proto"
    "notifications.proto"
    "health.proto"
    "search.proto"
    "batch.proto"
)

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        print_status "PASS" "Module exists: $module"
    else
        print_status "FAIL" "Module missing: $module"
    fi
done

# Check for README
if [ -f "$COMMON_DIR/README.md" ]; then
    print_status "PASS" "README.md exists"
else
    print_status "FAIL" "README.md missing"
fi

echo ""

# =============================================================================
# 2. PACKAGE NAMING VALIDATION
# =============================================================================

echo "2. Validating Package Naming..."
echo "-----------------------------------"

EXPECTED_PACKAGE="geniustechspace.common.v1"
PACKAGE_ERRORS=0

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        PACKAGE_LINE=$(grep "^package " "$COMMON_DIR/$module")
        if echo "$PACKAGE_LINE" | grep -q "$EXPECTED_PACKAGE"; then
            print_status "PASS" "Package correct in $module"
        else
            print_status "FAIL" "Package incorrect in $module: $PACKAGE_LINE"
            ((PACKAGE_ERRORS++))
        fi
    fi
done

if [ $PACKAGE_ERRORS -eq 0 ]; then
    print_status "PASS" "All packages use consistent naming"
fi

echo ""

# =============================================================================
# 3. LANGUAGE OPTIONS VALIDATION
# =============================================================================

echo "3. Validating Language Options..."
echo "-----------------------------------"

EXPECTED_OPTIONS=(
    "go_package"
    "java_multiple_files"
    "java_package"
    "csharp_namespace"
    "php_namespace"
    "ruby_package"
)

OPTIONS_ERRORS=0

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        for option in "${EXPECTED_OPTIONS[@]}"; do
            if grep -q "option $option" "$COMMON_DIR/$module"; then
                :  # Option found, no action needed
            else
                print_status "FAIL" "Missing $option in $module"
                ((OPTIONS_ERRORS++))
            fi
        done
    fi
done

if [ $OPTIONS_ERRORS -eq 0 ]; then
    print_status "PASS" "All modules have complete language options"
else
    print_status "WARN" "$OPTIONS_ERRORS language options missing"
fi

echo ""

# =============================================================================
# 4. DOCUMENTATION COVERAGE
# =============================================================================

echo "4. Calculating Documentation Coverage..."
echo "-----------------------------------"

TOTAL_LINES=0
DOC_LINES=0

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        MODULE_LINES=$(wc -l < "$COMMON_DIR/$module")
        MODULE_DOC_LINES=$(grep -c "^[ ]*//" "$COMMON_DIR/$module" || true)

        TOTAL_LINES=$((TOTAL_LINES + MODULE_LINES))
        DOC_LINES=$((DOC_LINES + MODULE_DOC_LINES))

        MODULE_COVERAGE=$((MODULE_DOC_LINES * 100 / MODULE_LINES))

        if [ $MODULE_COVERAGE -ge 50 ]; then
            print_status "PASS" "$module: ${MODULE_COVERAGE}% documentation coverage"
        else
            print_status "WARN" "$module: ${MODULE_COVERAGE}% documentation coverage (target: 50%+)"
        fi
    fi
done

OVERALL_COVERAGE=$((DOC_LINES * 100 / TOTAL_LINES))
print_status "INFO" "Overall documentation: $DOC_LINES lines across $TOTAL_LINES total lines"

if [ $OVERALL_COVERAGE -ge 50 ]; then
    print_status "PASS" "Overall documentation coverage: ${OVERALL_COVERAGE}%"
else
    print_status "FAIL" "Overall documentation coverage: ${OVERALL_COVERAGE}% (target: 50%+)"
fi

echo ""

# =============================================================================
# 5. COMPLIANCE ANNOTATIONS
# =============================================================================

echo "5. Checking Compliance Annotations..."
echo "-----------------------------------"

COMPLIANCE_PATTERNS=(
    "GDPR"
    "SOC 2"
    "ISO 27001"
    "HIPAA"
    "PCI DSS"
    "CCPA"
    "NIST 800-63B"
    "OAuth 2.0"
    "RFC"
    "CAN-SPAM"
    "TCPA"
)

TOTAL_COMPLIANCE=0

for pattern in "${COMPLIANCE_PATTERNS[@]}"; do
    COUNT=$(grep -r "$pattern" "$COMMON_DIR" --include="*.proto" | wc -l)
    TOTAL_COMPLIANCE=$((TOTAL_COMPLIANCE + COUNT))
    if [ $COUNT -gt 0 ]; then
        print_status "INFO" "$pattern: $COUNT references"
    fi
done

if [ $TOTAL_COMPLIANCE -ge 50 ]; then
    print_status "PASS" "Total compliance annotations: $TOTAL_COMPLIANCE"
else
    print_status "WARN" "Total compliance annotations: $TOTAL_COMPLIANCE (consider adding more)"
fi

echo ""

# =============================================================================
# 6. IMPORT DEPENDENCIES VALIDATION
# =============================================================================

echo "6. Validating Import Dependencies..."
echo "-----------------------------------"

# Define expected dependencies
declare -A MODULE_DEPS
MODULE_DEPS["base.proto"]="common/enums.proto"
MODULE_DEPS["metadata.proto"]="common/enums.proto"
MODULE_DEPS["auth.proto"]="common/enums.proto"
MODULE_DEPS["health.proto"]="common/enums.proto common/base.proto"
MODULE_DEPS["search.proto"]="common/pagination.proto common/enums.proto"
MODULE_DEPS["batch.proto"]="common/base.proto common/enums.proto"
MODULE_DEPS["files.proto"]="common/enums.proto"

IMPORT_ERRORS=0

for module in "${!MODULE_DEPS[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        for dep in ${MODULE_DEPS[$module]}; do
            if grep -q "import \"$dep\"" "$COMMON_DIR/$module"; then
                print_status "PASS" "$module correctly imports $dep"
            else
                print_status "FAIL" "$module missing import: $dep"
                ((IMPORT_ERRORS++))
            fi
        done
    fi
done

if [ $IMPORT_ERRORS -eq 0 ]; then
    print_status "PASS" "All import dependencies correct"
fi

echo ""

# =============================================================================
# 7. MESSAGE NAMING CONVENTIONS
# =============================================================================

echo "7. Validating Message Naming..."
echo "-----------------------------------"

NAMING_ERRORS=0

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        # Check for PascalCase message names
        MESSAGES=$(grep "^message " "$COMMON_DIR/$module" | grep -v "//" || true)
        while IFS= read -r line; do
            MESSAGE_NAME=$(echo "$line" | awk '{print $2}')
            if [[ $MESSAGE_NAME =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                :  # Valid PascalCase
            else
                print_status "FAIL" "Invalid message name in $module: $MESSAGE_NAME"
                ((NAMING_ERRORS++))
            fi
        done <<< "$MESSAGES"

        # Check for snake_case field names
        FIELDS=$(grep "^[ ]*[a-z_]* " "$COMMON_DIR/$module" | grep " = [0-9]*;" || true)
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                FIELD_NAME=$(echo "$line" | awk '{print $2}')
                if [[ $FIELD_NAME =~ ^[a-z][a-z0-9_]*$ ]]; then
                    :  # Valid snake_case
                else
                    if [[ $FIELD_NAME != "map<"* ]]; then
                        print_status "FAIL" "Invalid field name in $module: $FIELD_NAME"
                        ((NAMING_ERRORS++))
                    fi
                fi
            fi
        done <<< "$FIELDS"
    fi
done

if [ $NAMING_ERRORS -eq 0 ]; then
    print_status "PASS" "All message and field names follow conventions"
else
    print_status "WARN" "$NAMING_ERRORS naming convention issues found"
fi

echo ""

# =============================================================================
# 8. MODULE COUNT STATISTICS
# =============================================================================

echo "8. Module Statistics..."
echo "-----------------------------------"

MESSAGE_COUNT=0
ENUM_COUNT=0

for module in "${EXPECTED_MODULES[@]}"; do
    if [ -f "$COMMON_DIR/$module" ]; then
        MESSAGES=$(grep -c "^message " "$COMMON_DIR/$module" || true)
        ENUMS=$(grep -c "^enum " "$COMMON_DIR/$module" || true)

        MESSAGE_COUNT=$((MESSAGE_COUNT + MESSAGES))
        ENUM_COUNT=$((ENUM_COUNT + ENUMS))

        if [ $MESSAGES -gt 0 ] || [ $ENUMS -gt 0 ]; then
            print_status "INFO" "$module: $MESSAGES messages, $ENUMS enums"
        fi
    fi
done

print_status "INFO" "Total: $MESSAGE_COUNT messages, $ENUM_COUNT enums across ${#EXPECTED_MODULES[@]} modules"

echo ""

# =============================================================================
# FINAL SUMMARY
# =============================================================================

echo "========================================="
echo "Validation Summary"
echo "========================================="
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    print_status "PASS" "All critical checks passed ($CHECKS_PASSED total)"
    echo ""
    echo -e "${GREEN}✓ Module structure is valid and compliant${NC}"
    echo ""
    exit 0
else
    print_status "FAIL" "$CHECKS_FAILED checks failed, $CHECKS_PASSED passed"
    echo ""
    echo -e "${RED}✗ Module structure has issues requiring attention${NC}"
    echo ""
    exit 1
fi
