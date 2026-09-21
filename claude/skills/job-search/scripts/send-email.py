#!/usr/bin/env python3
"""Send the job-search digest via Gmail SMTP, reading the app password from macOS Keychain."""

import argparse
import smtplib
import ssl
import subprocess
import sys
from email.mime.text import MIMEText

GMAIL_ACCOUNT = "melissa.patterson.va@gmail.com"
KEYCHAIN_SERVICE = "job-search-gmail-app-password"


def get_app_password():
    result = subprocess.run(
        ["security", "find-generic-password", "-a", GMAIL_ACCOUNT, "-s", KEYCHAIN_SERVICE, "-w"],
        capture_output=True,
        text=True,
    )
    password = result.stdout.strip()
    if result.returncode != 0 or not password:
        print(
            f"Keychain item not found: service='{KEYCHAIN_SERVICE}' account='{GMAIL_ACCOUNT}'. "
            "Run the one-time setup in SKILL.md Prerequisites.",
            file=sys.stderr,
        )
        sys.exit(1)
    return password


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--subject", required=True)
    parser.add_argument("--body-file", required=True)
    parser.add_argument("--to", default=GMAIL_ACCOUNT)
    args = parser.parse_args()

    with open(args.body_file, "r") as f:
        body = f.read()

    password = get_app_password()

    msg = MIMEText(body)
    msg["Subject"] = args.subject
    msg["From"] = GMAIL_ACCOUNT
    msg["To"] = args.to

    try:
        context = ssl.create_default_context()
        with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
            server.login(GMAIL_ACCOUNT, password)
            server.sendmail(GMAIL_ACCOUNT, [args.to], msg.as_string())
    except (smtplib.SMTPException, ssl.SSLError, OSError) as e:
        print(f"Failed to send email: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"Sent: {args.subject} -> {args.to}")


if __name__ == "__main__":
    main()
