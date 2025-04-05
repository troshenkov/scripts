# scannedonlyd_clamav

**scannedonlyd_clamav** integrates [Scannedonly](http://olivier.sessink.nl/scannedonly/) with [ClamAV](https://www.clamav.net/), providing real-time, on-access virus scanning for Samba shares on Linux systems. This tool ensures that files written to specified directories are automatically scanned for malware, enhancing the security of shared resources.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Installation Steps](#installation-steps)
- [Configuration](#configuration)
  - [Configuration File](#configuration-file)
- [Usage](#usage)
  - [Starting the Service](#starting-the-service)
  - [Stopping the Service](#stopping-the-service)
  - [Restarting the Service](#restarting-the-service)
  - [Checking the Status](#checking-the-status)
- [Integration with Samba](#integration-with-samba)
- [Logging and Monitoring](#logging-and-monitoring)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Overview

**scannedonlyd_clamav** combines the functionalities of Scannedonly and ClamAV to provide a seamless solution for scanning files in real-time as they are accessed or written to Samba shares. Scannedonly acts as a virtual file system layer, intercepting file operations and ensuring that files are scanned by ClamAV before they are made accessible to users.

## Features

- **Real-time Scanning**: Automatically scans files upon access or modification.
- **Integration with ClamAV**: Leverages ClamAV's extensive virus database for detection.
- **Seamless Samba Integration**: Works transparently with Samba to secure shared directories.
- **Configurable Parameters**: Allows customization of scanning behavior and performance tuning.

## Installation

### Prerequisites

Before installing **scannedonlyd_clamav**, ensure that the following components are installed on your system:

- **ClamAV**: The antivirus engine used for scanning files. Installation instructions can be found in the [ClamAV Documentation](https://docs.clamav.net/manual/Installing.html).
- **Scannedonly**: A virtual file system layer for on-access scanning. More information is available on the [Scannedonly project page](http://olivier.sessink.nl/scannedonly/).

### Installation Steps

1. **Download scannedonlyd_clamav**: Obtain the latest version of **scannedonlyd_clamav** from the official repository or distribution source.

2. **Compile and Install**: Navigate to the downloaded source directory and execute the following commands:

   ```bash
   ./configure
   make
   sudo make install
