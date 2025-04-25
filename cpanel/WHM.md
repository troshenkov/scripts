# Roadmap for WHM Statistics Generator Script (whm_statistics_v2.sh)

## Version 2.0 (Current Version)
- **Features:**
  - Generates a detailed CSV report of domains hosted on a WHM/cPanel server.
  - Checks domain status (pingable or not).
  - Detects CMS types (e.g., Joomla) and fetches version details.
  - Extracts database credentials from configuration files.
  - Handles excluded and suspended accounts.
  - Logs errors and warnings to a log file.
  - Sends email notifications if issues are detected.

---

## Planned Improvements and Features

### **Version 2.1**
- **Error Handling:**
  - Add error handling for commands like `ping`, `idn`, `grep`, and `mailx`.
  - Gracefully handle missing or invalid data in `/etc/userdatadomains`.

- **Dependency Validation:**
  - Check for required utilities (`idn`, `ping`, `awk`, `grep`, `mailx`) at the start of the script.
  - Exit with a meaningful error message if any dependency is missing.

- **Logging Enhancements:**
  - Include timestamps in the `MESSAGE` log file for better debugging.
  - Add a summary of processed domains (e.g., total domains, online/offline counts).

- **Dry-Run Mode:**
  - Add a `--dry-run` option to test the script without making changes (e.g., no email notifications or file modifications).

---

### **Version 2.2**
- **Performance Optimization:**
  - Reduce redundant calls to external commands like `awk` and `grep` inside loops.
  - Use parallel processing for large datasets to improve performance.

- **CMS Detection:**
  - Extend CMS detection to include more CMS types (e.g., WordPress, Magento).
  - Add logic to fetch CMS-specific details like admin URLs and credentials.

- **Configuration File Support:**
  - Allow users to specify variables (e.g., `EMAIL`, `OUTPUT_FILE`, `LOG_FILE`) in a configuration file.

- **Improved Exclusion Handling:**
  - Add logic to skip excluded accounts during processing.

---

### **Version 2.3**
- **Enhanced Output:**
  - Add more details to the CSV report (e.g., SSL status, DNS records).
  - Include a column for domain expiration dates.

- **Temporary File Handling:**
  - Use temporary files for intermediate outputs and move them to the final location after successful execution.

- **Debug Mode:**
  - Add a `--debug` flag to print detailed logs for debugging purposes.

- **Unit Testing:**
  - Create unit tests for individual functions using a testing framework like [Bats](https://github.com/bats-core/bats-core).

---

### **Version 2.4**
- **Email Enhancements:**
  - Include a summary of the report in the email body.
  - Attach the CSV report to the email.

- **Database Integration:**
  - Add an option to store domain data in a database (e.g., MySQL).
  - Fetch additional details (e.g., registrar, paid-till date) from the database.

- **Localization:**
  - Add support for multiple languages in log messages and email notifications.

---

### **Version 3.0**
- **Web Interface:**
  - Develop a web-based interface for running the script and viewing reports.
  - Allow users to configure settings (e.g., excluded accounts, email recipients) via the web interface.

- **API Integration:**
  - Integrate with APIs (e.g., WHOIS, DNS) to fetch additional domain details.
  - Add support for third-party monitoring tools.

- **Advanced Reporting:**
  - Generate graphical reports (e.g., pie charts for domain statuses).
  - Export reports in multiple formats (e.g., JSON, XML).

---

## Timeline
| Version | Estimated Release Date | Key Features |
|---------|-------------------------|--------------|
| 2.1     | May 2025               | Error handling, dependency validation, dry-run mode |
| 2.2     | June 2025              | Performance optimization, extended CMS detection, configuration file support |
| 2.3     | July 2025              | Enhanced output, debug mode, unit testing |
| 2.4     | August 2025            | Email enhancements, database integration, localization |
| 3.0     | December 2025          | Web interface, API integration, advanced reporting |

---

## Contribution Guidelines
- Fork the repository and create a feature branch for your changes.
- Ensure all changes are tested before submitting a pull request.
- Follow the coding style and conventions used in the script.
- Include detailed comments and documentation for new features.

---

## Contact
For questions or suggestions, contact Dmitry Troshenkov at `troshenkov.d@gmail.com`.