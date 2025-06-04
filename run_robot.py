#!/usr/bin/env python3
"""
Robot Framework Test Runner with Enhanced Logging
This script provides advanced logging and error handling for Robot Framework tests.
"""

import os
import sys
import subprocess
import datetime
import argparse
import json
from pathlib import Path

class RobotTestRunner:
    def __init__(self, root_dir="."):
        self.root_dir = Path(root_dir).resolve()
        self.timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self.logs_dir = self.root_dir / "Logs"
        
    def setup_directories(self):
        """Create necessary directories"""
        self.logs_dir.mkdir(exist_ok=True)
        print(f"✓ Logs directory created: {self.logs_dir}")
        
    def run_test(self, keyword=None, license_plate=None, serial=None, headless=False):
        """Run the robot test with specified parameters"""
        
        # Build robot command
        cmd = [
            "robot",
            "-d", "./Logs",
        ]
        
        # Add variables
        if keyword:
            cmd.extend(["--variable", f"PARAMETERS.KEYWORD:{keyword}"])
        if license_plate:
            cmd.extend(["--variable", f"PARAMETERS.LICENSE:{license_plate}"])
        if serial:
            cmd.extend(["--variable", f"PARAMETERS.SERIAL:{serial}"])
        if headless:
            cmd.extend(["--variable", "CONFIG.BROWSER.DEFAULT:headlesschrome"])
            
        # Add robot file
        robot_file = self.root_dir / "stampcar-be8.robot"
        cmd.append(str(robot_file))
        
        print("=" * 60)
        print("🚀 Starting Robot Framework Test Execution")
        print(f"📅 Timestamp: {datetime.datetime.now()}")
        print(f"📁 Output Directory: {self.root_dir}")
        print("=" * 60)
        
        # Run the test
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.root_dir)
            
            print("=" * 60)
            print(f"✅ Robot Framework Test Execution Completed")
            print(f"🔢 Command: {cmd}")
            print(f"🔢 Exit Code: {result.returncode}")
            print(f"📅 Timestamp: {datetime.datetime.now()}")
            
            if result.returncode != 0:
                print("❌ TEST FAILED - Check the following files for details:")
                print(f"  📷 Screenshots in: {self.logs_dir}")
                
                print("\n📁 Latest files also available as:")
                print("  📄 log.html")
                print("  📊 report.html") 
                print("  🗂️  output.xml")
                
                if result.stderr:
                    print(f"\n❌ Error Output:\n{result.stderr}")
                    
            else:
                print("✅ TEST PASSED - Check the following files for details:")
                
            print("=" * 60)
            return result.returncode
            
        except Exception as e:
            print(f"❌ Error running robot test: {e}")
            return 1
            
    def _copy_to_standard_names(self, log_file, report_file, output_xml):
        """Copy files to standard names for easy access"""
        try:
            if log_file.exists():
                (self.root_dir / "log.html").write_bytes(log_file.read_bytes())
            if report_file.exists():
                (self.root_dir / "report.html").write_bytes(report_file.read_bytes())
            if output_xml.exists():
                (self.root_dir / "output.xml").write_bytes(output_xml.read_bytes())
        except Exception as e:
            print(f"⚠️  Warning: Could not copy to standard names: {e}")

def main():
    parser = argparse.ArgumentParser(description='Run Robot Framework tests with enhanced logging')
    parser.add_argument('--keyword', help='Search keyword')
    parser.add_argument('--license', help='License plate number')
    parser.add_argument('--serial', help='Serial number')
    parser.add_argument('--headless', action='store_true', help='Run in headless mode')
    parser.add_argument('--root-dir', default='.', help='Root directory for output files')
    
    args = parser.parse_args()
    
    runner = RobotTestRunner(args.root_dir)
    runner.setup_directories()
    
    exit_code = runner.run_test(
        keyword=args.keyword,
        license_plate=args.license,
        serial=args.serial,
        headless=args.headless
    )
    
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
