#!/bin/bash

# Color codes
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Functions
pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

warn() {
  echo -e "${RED}[FAIL]${NC} $1"
}

info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

not_found() {
  echo -e "${BLUE}[INFO]${NC} ${PURPLE}[NOT FOUND]${NC} $1"
}

remediation() {
  echo -e "${RED}[REMEDIATION]${NC} $1"
}

file_apiserver="/etc/kubernetes/manifests/kube-apiserver.yaml"

# Check 1.2.1
check_1_2_1="1.2.1 - Ensure that the --anonymous-auth argument is set to false (Manual)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' > /dev/null; then
  # Use awk to find if --anonymous-auth is set to false
  if awk '/--anonymous-auth/ && /false/' "$file_apiserver" > /dev/null; then
    pass "$check_1_2_1"
  else
    warn "$check_1_2_1"
    warn "     * --anonymous-auth is not set to false"
    remediation "Edit the API server manifest file $file_apiserver and set --anonymous-auth=false"
  fi
else
  not_found "$check_1_2_1"
fi

# Check 1.2.2
check_1_2_2="1.2.2 - Ensure that the --token-auth-file parameter is not set (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' > /dev/null; then
  # Check if --token-auth-file is present in the command
  if ps -ef | grep '[k]ube-apiserver' | grep -- '--token-auth-file' > /dev/null; then
    warn "$check_1_2_2"
    warn "     * --token-auth-file parameter is set"
    remediation "Edit the API server manifest file $file_apiserver and remove the --token-auth-file=<filename> parameter."
  else
    pass "$check_1_2_2"
  fi
else
  not_found "$check_1_2_2"
fi

# Check 1.2.3
check_1_2_3="1.2.3 - Ensure that the DenyServiceExternalIPs is set (Manual)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' > /dev/null; then
  # Check if DenyServiceExternalIPs is disabled
  if ps -ef | grep 'kube-apiserver' | grep -- '--disable-admission-plugins' | grep -q 'DenyServiceExternalIPs'; then
    warn "$check_1_2_3"
    warn "     * DenyServiceExternalIPs is disabled"
    remediation "Edit the API server manifest file $file_apiserver and remove the --disable-admission-plugins=DenyServiceExternalIPs parameter to enable it."
  else
    pass "$check_1_2_3"
  fi
else
  not_found "$check_1_2_3"
fi
# Check 1.2.4
check_1_2_4="1.2.4 - Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' > /dev/null; then
  # Check for kubelet-client-certificate and kubelet-client-key arguments
  if ps -ef | grep 'kube-apiserver' | grep -- '--kubelet-client-certificate' | grep -- '--kubelet-client-key' > /dev/null; then
    pass "$check_1_2_4"
  else
    warn "$check_1_2_4"
    warn "     * --kubelet-client-certificate or --kubelet-client-key is not set or missing"
    remediation "Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set --kubelet-client-certificate=<path/to/client-certificate-file> and --kubelet-client-key=<path/to/client-key-file>"
  fi
else
  not_found "$check_1_2_4"
fi

# Check 1.2.5
check_1_2_5="1.2.5 - Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' > /dev/null; then
  # Check for kubelet-certificate-authority argument
  if ps -ef | grep 'kube-apiserver' | grep -- '--kubelet-certificate-authority' > /dev/null; then
    pass "$check_1_2_5"
  else
    warn "$check_1_2_5"
    warn "     * --kubelet-certificate-authority argument is not set or missing"
    remediation "Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set --kubelet-certificate-authority=<path/to/ca-file>"
  fi
else
  not_found "$check_1_2_5"
fi

# Check 1.2.6
check_1_2_6="1.2.6 - Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--authorization-mode=AlwaysAllow' > /dev/null; then
  warn "$check_1_2_6"
  warn "     * --authorization-mode is set to AlwaysAllow"
  echo "REMEDIATION: Edit the API server manifest file $file_apiserver and set --authorization-mode to values other than AlwaysAllow, such as --authorization-mode=RBAC"
else
  pass "$check_1_2_6"
fi

check_1_2_7="1.2.7 - Ensure that the --authorization-mode argument includes Node (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--authorization-mode=' | grep -E '(Node,RBAC|RBAC,Node)' > /dev/null; then
  pass "$check_1_2_7"
else
  warn "$check_1_2_7"
  warn "     * --authorization-mode argument does not include Node"
  remediation "Edit the API server manifest file $file_apiserver and set --authorization-mode to a value that includes Node, such as --authorization-mode=Node,RBAC or --authorization-mode=RBAC,Node"
fi
check_1_2_8="1.2.8 - Ensure that the --authorization-mode argument includes RBAC (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--authorization-mode=' | grep -E 'RBAC' > /dev/null; then
  pass "$check_1_2_8"
else
  warn "$check_1_2_8"
  warn "     * --authorization-mode argument does not include RBAC"
  remediation "Edit the API server manifest file $file_apiserver and set --authorization-mode to a value that includes RBAC, such as --authorization-mode=Node,RBAC or --authorization-mode=RBAC,Node"
fi


check_1_2_9="1.2.9 - Ensure that the admission control plugin EventRateLimit is set (Manual)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--enable-admission-plugins=' | grep -E 'EventRateLimit' > /dev/null; then
  pass "$check_1_2_9"
else
  warn "$check_1_2_9"
  warn "     * --enable-admission-plugins argument does not include EventRateLimit"
  remediation "Edit the API server manifest file $file_apiserver and ensure that the --enable-admission-plugins argument includes EventRateLimit, and configure the rate limits appropriately."
fi
check_1_2_10="1.2.10 - Ensure that the admission control plugin AlwaysAdmit is not set (Automated)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--enable-admission-plugins' | grep -q 'AlwaysAdmit'; then
  warn "$check_1_2_10"
  warn "     * --enable-admission-plugins argument includes AlwaysAdmit"
  remediation "Edit the API server manifest file $file_apiserver and ensure that the --enable-admission-plugins argument does not include AlwaysAdmit."
else
  pass "$check_1_2_10"
fi

check_1_2_11="1.2.11 - Ensure that the admission control plugin AlwaysPullImages is set (Manual)"

# Check if kube-apiserver is running
if ps -ef | grep '[k]ube-apiserver' | grep -- '--enable-admission-plugins' | grep -q 'AlwaysPullImages'; then
  pass "$check_1_2_11"
else
  warn "$check_1_2_11"
  warn "     * --enable-admission-plugins argument does not include AlwaysPullImages"
  remediation "Edit the API server manifest file $file_apiserver and set --enable-admission-plugins to include AlwaysPullImages."
fi

# Check 1.2.12
check_1_2_12="1.2.12 - Ensure that the admission control plugin ServiceAccount is set (Automated)"

# Check if kube-apiserver is running and if --disable-admission-plugins includes ServiceAccount
if ps -ef | grep '[k]ube-apiserver' | grep -q -- '--disable-admission-plugins'; then
  if ps -ef | grep '[k]ube-apiserver' | grep -- '--disable-admission-plugins' | grep -q 'ServiceAccount'; then
    warn "$check_1_2_12"
    warm "     * --disable-admission-plugins includes ServiceAccount"
    echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and ensure that --disable-admission-plugins does not include ServiceAccount."
  else
    pass "$check_1_2_12"
  fi
else
  warn "$check_1_2_12"
  warn "     * --disable-admission-plugins argument is not set"
  echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and ensure that --disable-admission-plugins does not include ServiceAccount."
fi

check_1_2_13="1.2.13 - Ensure that the --disable-admission-plugins argument does not include NamespaceLifecycle (Automated)"

if ps -ef | grep '[k]ube-apiserver' | grep -- '--disable-admission-plugins=.*NamespaceLifecycle.*' > /dev/null; then
  fail "$check_1_2_13"
  echo "    * --disable-admission-plugins argument includes NamespaceLifecycle"
  echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and ensure that --disable-admission-plugins does not include NamespaceLifecycle."
else
  pass "$check_1_2_13"
fi

# Check 1.2.14
check_1_2_14="1.2.14 - Ensure that the admission control plugin NodeRestriction is set (Automated)"

# Check if kube-apiserver is running and if the --enable-admission-plugins argument includes NodeRestriction
if ps -ef | grep '[k]ube-apiserver' | grep -q -- '--enable-admission-plugins'; then
  if ps -ef | grep '[k]ube-apiserver' | grep -- '--enable-admission-plugins' | grep -q 'NodeRestriction'; then
    pass "$check_1_2_14"
  else
    fail "$check_1_2_14"
    echo "    * --enable-admission-plugins argument does not include NodeRestriction"
    echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set the --enable-admission-plugins parameter to a value that includes NodeRestriction, e.g., --enable-admission-plugins=...,NodeRestriction,..."
  fi
else
  fail "$check_1_2_14"
  echo "    * --enable-admission-plugins argument is not set"
  echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and ensure that --enable-admission-plugins includes NodeRestriction."
fi
# Check 1.2.15
check_1_2_15="1.2.15 - Ensure that the --profiling argument is set to false (Automated)"

# Check if kube-apiserver is running and if the --profiling argument is set to false
if ps -ef | grep '[k]ube-apiserver' | grep -q -- '--profiling'; then
  if ps -ef | grep '[k]ube-apiserver' | grep -- '--profiling' | grep -q 'false'; then
    pass "$check_1_2_15"
  else
    warn "$check_1_2_15"
    echo "    * --profiling argument is not set to false"
    echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set the --profiling parameter to false, e.g., --profiling=false"
  fi
else
  warn "$check_1_2_15"
  echo "    * --profiling argument is not set"
  echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and ensure that --profiling is set to false."
fi

# Check 1.2.16
check_1_2_16="1.2.16 - Ensure that the --audit-log-path argument is set (Automated)"

# Check if kube-apiserver is running and if the --audit-log-path argument is set
if ps -ef | grep '[k]ube-apiserver' | grep -q -- '--audit-log-path'; then
  if ps -ef | grep '[k]ube-apiserver' | grep -- '--audit-log-path' | grep -q '/'; then
    pass "$check_1_2_16"
  else
    warn "$check_1_2_16"
    echo "    * --audit-log-path argument is set but does not specify a valid path"
    echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set the --audit-log-path parameter to a suitable path and file, e.g., --audit-log-path=/var/log/apiserver/audit.log"
  fi
else
  warn "$check_1_2_16"
  echo "    * --audit-log-path argument is not set"
  echo "REMEDIATION: Edit the API server manifest file /etc/kubernetes/manifests/kube-apiserver.yaml and set the --audit-log-path parameter to a suitable path and file, e.g., --audit-log-path=/var/log/apiserver/audit.log"
fi


