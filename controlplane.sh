#!/bin/bash

# Color codes
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File locations
file_apiserver="/etc/kubernetes/manifests/kube-apiserver.yaml"
file_controllermanager="/etc/kubernetes/manifests/kube-controller-manager.yaml"
file_scheduler="/etc/kubernetes/manifests/kube-scheduler.yaml"
file_etcd="/etc/kubernetes/manifests/kube-etcd.yaml" # Define if missing

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

# Check 1.1.1
check_1_1_1="1.1.1 - Ensure that the API server pod specification file permissions are set to 600 or more restrictive (Automated)"
if [ -f "$file_apiserver" ]; then
  permissions=$(stat -c %a "$file_apiserver")
  if [ "$permissions" -le 600 ]; then
    pass "$check_1_1_1"
  else
    warn "$check_1_1_1"
    warn "     * Wrong permissions for $file_apiserver"
    remediation "chmod 600 $file_apiserver"
  fi
else
  not_found "$check_1_1_1"
fi

# Check 1.1.2
check_1_1_2="1.1.2 - Ensure that the API server pod specification file ownership is set to root:root (Automated)"
if [ -f "$file_apiserver" ]; then
  ownership=$(stat -c %U:%G "$file_apiserver")
  if [ "$ownership" = "root:root" ]; then
    pass "$check_1_1_2"
  else
    warn "$check_1_1_2"
    warn "     * Wrong ownership for $file_apiserver"
    remediation "chown root:root $file_apiserver"
  fi
else
  not_found "$check_1_1_2"
fi

# Check 1.1.3
check_1_1_3="1.1.3 - Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive (Automated)"
if [ -f "$file_controllermanager" ]; then
  permissions=$(stat -c %a "$file_controllermanager")
  if [ "$permissions" -le 600 ]; then
    pass "$check_1_1_3"
  else
    warn "$check_1_1_3"
    warn "     * Wrong permissions for $file_controllermanager"
    remediation "chmod 600 $file_controllermanager"
  fi
else
  not_found "$check_1_1_3"
fi


# Check 1.1.4
check_1_1_4="1.1.4 - Ensure that the controller manager pod specification file ownership is set to root:root (Automated)"
if [ -f "$file_controllermanager" ]; then
  ownership=$(stat -c %U:%G "$file_controllermanager")
  if [ "$ownership" = "root:root" ]; then
    pass "$check_1_1_4"
  else
    warn "$check_1_1_4"
    warn "     * Wrong ownership for $file_controllermanager"
    remediation "chown root:root $file_controllermanager"
  fi
else
  not_found "$check_1_1_4"
fi

# Check 1.1.5
check_1_1_5="1.1.5 - Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive (Automated)"
if [ -f "$file_scheduler" ]; then
  permissions=$(stat -c %a "$file_scheduler")
  if [ "$permissions" -le 600 ]; then
    pass "$check_1_1_5"
  else
    warn "$check_1_1_5"
    warn "     * Wrong permissions for $file_scheduler"
    remediation "chmod 600 $file_scheduler"
  fi
else
  not_found "$check_1_1_5"
fi

# Check 1.1.6
check_1_1_6="1.1.6 - Ensure that the scheduler pod specification file ownership is set to root:root (Automated)"
if [ -f "$file_scheduler" ]; then
  ownership=$(stat -c %U:%G "$file_scheduler")
  if [ "$ownership" = "root:root" ]; then
    pass "$check_1_1_6"
  else
    warn "$check_1_1_6"
    warn "     * Wrong ownership for $file_scheduler"
    remediation "chown root:root $file_scheduler"
  fi
else
  not_found "$check_1_1_6"
fi

# Check 1.1.7
check_1_1_7="1.1.7 - Ensure that the etcd pod specification file permissions are set to 600 or more restrictive (Automated)"
if [ -f "$file_etcd" ]; then
  permissions=$(stat -c %a "$file_etcd")
  if [ "$permissions" -le 600 ]; then
    pass "$check_1_1_7"
  else
    warn "$check_1_1_7"
    warn "     * Wrong permissions for $file_etcd"
    remediation "chmod 600 $file_etcd"
  fi
else
  not_found "$check_1_1_7"
fi

# Check 1.1.8
check_1_1_8="1.1.8 - Ensure that the etcd pod specification file ownership is set to root:root (Automated)"
if [ -f "$file_etcd" ]; then
  ownership=$(stat -c %U:%G "$file_etcd")
  if [ "$ownership" = "root:root" ]; then
    pass "$check_1_1_8"
  else
    warn "$check_1_1_8"
    warn "     * Wrong ownership for $file_etcd"
    remediation "chown root:root $file_etcd"
  fi
else
  not_found "$check_1_1_8"
fi
# Common paths for CNI files
cni_paths="/etc/cni/net.d/ /opt/cni/bin/ /etc/kubernetes/cni/"

# Check 1.1.9 - Container Network Interface file permissions
check_1_1_9="1.1.9 - Ensure that the Container Network Interface file permissions are set to 600 or more restrictive (Manual)"
found_files=0
pass_status=1  # Assume pass by default

for path in $cni_paths; do
  if [ -d "$path" ]; then
    for file in "$path"/*; do
      if [ -f "$file" ]; then
        permissions=$(stat -c %a "$file")
        if [ "$permissions" -gt 600 ]; then
          pass_status=0  # Fail if any file does not meet the criteria
          warn "$check_1_1_9"
          warn "     * Wrong permissions for $file"
          remediation "chmod 600 $file"
        fi
        found_files=1
      fi
    done
  fi
done

if [ "$found_files" -eq 0 ]; then
  not_found "$check_1_1_9"
else
  if [ "$pass_status" -eq 1 ]; then
    pass "$check_1_1_9"
  else
    fail "$check_1_1_9"
  fi
fi

# Define paths for CNI files
cni_paths="/etc/cni/net.d/ /opt/cni/bin/ /etc/kubernetes/cni/"

# Check 1.1.10 - Container Network Interface file ownership
check_1_1_10="1.1.10 - Ensure that the Container Network Interface file ownership is set to root:root (Manual)"
found_files=0
pass_status=1  # Assume pass by default

for path in $cni_paths; do
  if [ -d "$path" ]; then
    for file in "$path"/*; do
      if [ -f "$file" ]; then
        ownership=$(stat -c %U:%G "$file")
        if [ "$ownership" != "root:root" ]; then
          pass_status=0  # Fail if any file does not meet the criteria
          warn "$check_1_1_10"
          warn "     * Wrong ownership for $file"
          remediation "chown root:root $file"
        fi
        found_files=1
      fi
    done
  fi
done

if [ "$found_files" -eq 0 ]; then
  not_found "$check_1_1_10"
else
  if [ "$pass_status" -eq 1 ]; then
    pass "$check_1_1_10"
  else
    warn "$check_1_1_10"
  fi
fi






# Check 1.1.11 - Ensure that the etcd data directory permissions are set to 700 or more restrictive
check_1_1_11="1.1.11 - Ensure that the etcd data directory permissions are set to 700 or more restrictive (Automated)"

# Get the etcd data directory from the etcd process arguments
etcd_data_dir=$(ps -ef | grep etcd | grep -- -data-dir | awk -F '--data-dir=' '{print $2}' | awk '{print $1}')

if [ -n "$etcd_data_dir" ]; then
  if [ -d "$etcd_data_dir" ]; then
    permissions=$(stat -c %a "$etcd_data_dir")
    if [ "$permissions" -le 700 ]; then
      pass "$check_1_1_11"
    else
      warn "$check_1_1_11"
      warn "     * Wrong permissions for $etcd_data_dir"
      remediation "chmod 700 $etcd_data_dir"
    fi
  else
    not_found "$check_1_1_11"
    info "     * etcd data directory not found: $etcd_data_dir"
  fi
else
  not_found "$check_1_1_11"
  info "     * etcd data directory not found"
fi

# Check 1.1.12 - Ensure that the etcd data directory ownership is set to etcd:etcd
check_1_1_12="1.1.12 - Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)"

# Get the etcd data directory from the etcd process arguments
etcd_data_dir=$(ps -ef | grep etcd | grep -- -data-dir | awk -F '--data-dir=' '{print $2}' | awk '{print $1}')

if [ -n "$etcd_data_dir" ]; then
  if [ -d "$etcd_data_dir" ]; then
    ownership=$(stat -c %U:%G "$etcd_data_dir")
    if [ "$ownership" = "etcd:etcd" ]; then
      pass "$check_1_1_12"
    else
      warn "$check_1_1_12"
      warn "     * Wrong ownership for $etcd_data_dir"
      remediation "chown etcd:etcd $etcd_data_dir"
    fi
  else
    not_found "$check_1_1_12"
    info "     * etcd data directory not found: $etcd_data_dir"
  fi
else
  not_found "$check_1_1_12"
  info "     * etcd data directory not found"
fi

# Files to check
file_admin="/etc/kubernetes/admin.conf"
file_super_admin="/etc/kubernetes/super-admin.conf"

# Check 1.1.13 - Default Administrative Credential File Permissions
check_1_1_13="1.1.13 - Ensure that the default administrative credential file permissions are set to 600 (Automated)"

check_permissions() {
  local file="$1"
  local check_msg="$2"
  
  if [ -f "$file" ]; then
    permissions=$(stat -c %a "$file")
    if [ "$permissions" -le 600 ]; then
      pass "$check_msg"
    else
      warn "$check_msg"
      warn "     * Wrong permissions for $file"
      remediation "chmod 600 $file"
    fi
  else
    not_found "$check_msg"
    info "     * File not found: $file"
  fi
}

# Perform checks for admin.conf
check_permissions "$file_admin" "$check_1_1_13"

# Perform checks for super-admin.conf, if it exists (Kubernetes 1.29+)
if [ -f "$file_super_admin" ]; then
  check_permissions "$file_super_admin" "$check_1_1_13"
else
  not_found "$check_1_1_13"
  info "     * $file_super_admin not found"
fi


# Check 1.1.14 - Default Administrative Credential File Ownership
check_1_1_14="1.1.14 - Ensure that the default administrative credential file ownership is set to root:root (Automated)"
found_files=0
pass_status=1  # Assume pass by default

# Files to check
file_admin="/etc/kubernetes/admin.conf"
file_super_admin="/etc/kubernetes/super-admin.conf"

# Function to check ownership and apply remediation if needed
check_ownership() {
  local file="$1"
  local check_msg="$2"
  
  if [ -f "$file" ]; then
    ownership=$(stat -c %U:%G "$file")
    if [ "$ownership" != "root:root" ]; then
      # Incorrect ownership
      pass_status=0
      warn "$check_msg"
      warn "     * Wrong ownership for $file"
      remediation "chown root:root $file"
    fi
    found_files=1
  else
    # File not found
    not_found "$check_msg"
    info "     * File not found: $file"
  fi
}

# Perform checks for admin.conf
check_ownership "$file_admin" "$check_1_1_14"

# Perform checks for super-admin.conf, if it exists (Kubernetes 1.29+)
check_ownership "$file_super_admin" "$check_1_1_14"

# Final check to print pass or fail status
if [ "$found_files" -eq 0 ]; then
  not_found "$check_1_1_14"
elif [ "$pass_status" -eq 1 ]; then
  pass "$check_1_1_14"
else
  fail "$check_1_1_14"
fi

# Check 1.1.15 - Scheduler Configuration File Permissions
check_1_1_15="1.1.15 - Ensure that the scheduler.conf file permissions are set to 600 or more restrictive (Automated)"
file_scheduler="/etc/kubernetes/scheduler.conf"
found_file=0
pass_status=1  # Assume pass by default

if [ -f "$file_scheduler" ]; then
  # File exists, check permissions
  permissions=$(stat -c %a "$file_scheduler")
  if [ "$permissions" -lt 600 ]; then
    # Permissions are less restrictive than 600
    pass_status=0
    warn "$check_1_1_15"
    warn "     * Wrong permissions for $file_scheduler"
    remediation "chmod 600 $file_scheduler"
  fi
  found_file=1
else
  # File not found
  not_found "$check_1_1_15"
  info "     * File not found: $file_scheduler"
fi

# Final check to print pass or fail status
if [ "$found_file" -eq 0 ]; then
  not_found "$check_1_1_15"
elif [ "$pass_status" -eq 1 ]; then
  pass "$check_1_1_15"
else
  fail "$check_1_1_15"
fi

# Check 1.1.16 - Scheduler Configuration File Ownership
check_1_1_16="1.1.16 - Ensure that the scheduler.conf file ownership is set to root:root (Automated)"
file_scheduler="/etc/kubernetes/scheduler.conf"
found_file=0
pass_status=1  # Assume pass by default

if [ -f "$file_scheduler" ]; then
  # File exists, check ownership
  ownership=$(stat -c %U:%G "$file_scheduler")
  if [ "$ownership" != "root:root" ]; then
    # Ownership is not root:root
    pass_status=0
    warn "$check_1_1_16"
    warn "     * Wrong ownership for $file_scheduler"
    remediation "chown root:root $file_scheduler"
  fi
  found_file=1
else
  # File not found
  not_found "$check_1_1_16"
  info "     * File not found: $file_scheduler"
fi

# Final check to print pass or fail status
if [ "$found_file" -eq 0 ]; then
  not_found "$check_1_1_16"
elif [ "$pass_status" -eq 1 ]; then
  pass "$check_1_1_16"
else
  fail "$check_1_1_16"
fi

# Check 1.1.17 - Controller Manager Configuration File Permissions
check_1_1_17="1.1.17 - Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive (Automated)"
file_controller_manager="/etc/kubernetes/controller-manager.conf"
found_file=0
pass_status=1  # Assume pass by default

if [ -f "$file_controller_manager" ]; then
  # File exists, check permissions
  permissions=$(stat -c %a "$file_controller_manager")
  if [ "$permissions" -lt 600 ]; then
    # Permissions are less than 600
    pass_status=0
    warn "$check_1_1_17"
    warn "     * Wrong permissions for $file_controller_manager"
    remediation "chmod 600 $file_controller_manager"
  fi
  found_file=1
else
  # File not found
  not_found "$check_1_1_17"
  info "     * File not found: $file_controller_manager"
fi

# Final check to print pass or fail status
if [ "$found_file" -eq 0 ]; then
  not_found "$check_1_1_17"
elif [ "$pass_status" -eq 1 ]; then
  pass "$check_1_1_17"
else
  fail "$check_1_1_17"
fi
# Check 1.1.18 - Controller Manager Configuration File Ownership
check_1_1_18="1.1.18 - Ensure that the controller-manager.conf file ownership is set to root:root (Automated)"
file_controller_manager="/etc/kubernetes/controller-manager.conf"
found_file=0
pass_status=1  # Assume pass by default

if [ -f "$file_controller_manager" ]; then
  # File exists, check ownership
  ownership=$(stat -c %U:%G "$file_controller_manager")
  if [ "$ownership" != "root:root" ]; then
    # Ownership is not root:root
    pass_status=0
    warn "$check_1_1_18"
    warn "     * Wrong ownership for $file_controller_manager"
    remediation "chown root:root $file_controller_manager"
  fi
  found_file=1
else
  # File not found
  not_found "$check_1_1_18"
  info "     * File not found: $file_controller_manager"
fi

# Final check to print pass or fail status
if [ "$found_file" -eq 0 ]; then
  not_found "$check_1_1_18"
elif [ "$pass_status" -eq 1 ]; then
  pass "$check_1_1_18"
else
  fail "$check_1_1_18"
fi
# Check 1.1.19 - Kubernetes PKI Directory and File Ownership
check_1_1_19="1.1.19 - Ensure that the Kubernetes PKI directory and file ownership is set to root:root (Automated)"
pki_dir="/etc/kubernetes/pki"
found_files=0
pass_status=1  # Assume pass by default

if [ -d "$pki_dir" ]; then
  # Directory exists, check ownership recursively
  incorrect_ownership=0
  while IFS= read -r -d '' file; do
    ownership=$(stat -c %U:%G "$file")
    if [ "$ownership" != "root:root" ]; then
      incorrect_ownership=1
      pass_status=0
      warn "$check_1_1_19"
      warn "     * Wrong ownership for $file"
      remediation "chown -R root:root $pki_dir"
    fi
    found_files=1
  done < <(find "$pki_dir" -print0)
  
  if [ $incorrect_ownership -eq 0 ]; then
    pass "$check_1_1_19"
  fi
else
  # Directory not found
  not_found "$check_1_1_19"
  info "     * Directory not found: $pki_dir"
fi

# Check 1.1.20 - Kubernetes PKI Certificate File Permissions
check_1_1_20="1.1.20 - Ensure that the Kubernetes PKI certificate file permissions are set to 600 or more restrictive (Manual)"
pki_cert_dir="/etc/kubernetes/pki"
pass_status=1 

if [ -d "$pki_cert_dir" ]; then
  for cert_file in "$pki_cert_dir"/*.crt; do
    if [ -f "$cert_file" ]; then
      perms=$(stat -c '%a' "$cert_file")
      if [ "$perms" -le 600 ]; then
        # Correct permissions, no action needed
        continue
      else
        # Incorrect permissions
        pass_status=0
        warn "$check_1_1_20"
        warn "     * Wrong permissions for $cert_file"
        remediation "chmod 600 $cert_file"
      fi
    fi
  done

  if [ "$pass_status" -eq 1 ]; then
    pass "$check_1_1_20"
  fi
else
  not_found "$check_1_1_20"
  info "     * Directory not found: $pki_cert_dir"
fi

# Check 1.1.21 - Kubernetes PKI Key File Permissions
check_1_1_21="1.1.21 - Ensure that the Kubernetes PKI key file permissions are set to 600 (Manual)"
pki_key_dir="/etc/kubernetes/pki"
pass_status=1  # Assume pass by default

# Check if the PKI directory exists
if [ -d "$pki_key_dir" ]; then
  # Find all .key files and check their permissions
  for key_file in "$pki_key_dir"/*.key; do
    if [ -f "$key_file" ]; then
      perms=$(stat -c '%a' "$key_file")
      if [ "$perms" -eq 600 ]; then
        # Correct permissions, no action needed
        continue
      else
        # Incorrect permissions
        pass_status=0
        warn "$check_1_1_21"
        warn "     * Wrong permissions for $key_file"
        remediation "chmod 600 $key_file"
      fi
    fi
  done

  if [ "$pass_status" -eq 1 ]; then
    pass "$check_1_1_21"
  fi
else
  not_found "$check_1_1_21"
  info "     * Directory not found: $pki_key_dir"
fi
