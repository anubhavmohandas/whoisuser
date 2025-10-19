#!/usr/bin/env python3
"""
WhoisUser - Professional Username OSINT & Forensic Investigation Tool
Author: Anubhav
Description: Automated username enumeration with integrated OSINT tools
"""

import requests
import json
import os
import sys
from datetime import datetime
from pathlib import Path
import time
from colorama import Fore, Style, init
import concurrent.futures
import subprocess
import shutil

# Initialize colorama
init(autoreset=True)

class WhoisUser:
    def __init__(self, username):
        self.username = username
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.output_dir = f"investigations/{username}_{self.timestamp}"
        self.images_dir = f"{self.output_dir}/screenshots"
        self.osint_dir = f"{self.output_dir}/osint_results"
        self.found_profiles = []
        self.sherlock_results = []
        
        # Create output directories
        Path(self.output_dir).mkdir(parents=True, exist_ok=True)
        Path(self.images_dir).mkdir(parents=True, exist_ok=True)
        Path(self.osint_dir).mkdir(parents=True, exist_ok=True)
        
        # Check for available OSINT tools
        self.available_tools = self.check_osint_tools()
        
        # Comprehensive platform list (100 platforms)
        self.platforms = self.get_all_platforms()
        
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        }

    def check_osint_tools(self):
        """Check which OSINT tools are available on the system"""
        tools = {
            'sherlock': shutil.which('sherlock'),
            'maigret': shutil.which('maigret'),
            'social-analyzer': shutil.which('social-analyzer'),
            'holehe': shutil.which('holehe'),
            'blackbird': shutil.which('blackbird'),
        }
        return {name: path for name, path in tools.items() if path}

    def get_all_platforms(self):
        """Returns dictionary of all 100+ platforms to check"""
        username = self.username
        
        platforms = {
            # === MAJOR SOCIAL MEDIA ===
            "Instagram": f"https://www.instagram.com/{username}/",
            "Twitter/X": f"https://twitter.com/{username}",
            "Facebook": f"https://www.facebook.com/{username}",
            "LinkedIn": f"https://www.linkedin.com/in/{username}",
            "TikTok": f"https://www.tiktok.com/@{username}",
            "Snapchat": f"https://www.snapchat.com/add/{username}",
            "Reddit": f"https://www.reddit.com/user/{username}",
            "Pinterest": f"https://www.pinterest.com/{username}",
            "Tumblr": f"https://{username}.tumblr.com",
            "Mastodon": f"https://mastodon.social/@{username}",
            
            # === VIDEO PLATFORMS ===
            "YouTube": f"https://www.youtube.com/@{username}",
            "Vimeo": f"https://vimeo.com/{username}",
            "Dailymotion": f"https://www.dailymotion.com/{username}",
            "Twitch": f"https://www.twitch.tv/{username}",
            "Rumble": f"https://rumble.com/user/{username}",
            "BitChute": f"https://www.bitchute.com/channel/{username}",
            
            # === DEVELOPER PLATFORMS ===
            "GitHub": f"https://github.com/{username}",
            "GitLab": f"https://gitlab.com/{username}",
            "Bitbucket": f"https://bitbucket.org/{username}",
            "StackOverflow": f"https://stackoverflow.com/users/{username}",
            "HackerRank": f"https://www.hackerrank.com/{username}",
            "LeetCode": f"https://leetcode.com/{username}",
            "CodePen": f"https://codepen.io/{username}",
            "Repl.it": f"https://replit.com/@{username}",
            "Dev.to": f"https://dev.to/{username}",
            "Kaggle": f"https://www.kaggle.com/{username}",
            "HackerOne": f"https://hackerone.com/{username}",
            "CodeChef": f"https://www.codechef.com/users/{username}",
            
            # === GAMING PLATFORMS ===
            "Steam": f"https://steamcommunity.com/id/{username}",
            "Xbox": f"https://xboxgamertag.com/search/{username}",
            "PlayStation": f"https://psnprofiles.com/{username}",
            "Discord": f"https://discord.com/users/{username}",
            "Roblox": f"https://www.roblox.com/users/profile?username={username}",
            "Epic Games": f"https://www.epicgames.com/site/en-US/profile/{username}",
            "Fortnite": f"https://fortnitetracker.com/profile/all/{username}",
            "Minecraft": f"https://namemc.com/profile/{username}",
            
            # === PROFESSIONAL NETWORKS ===
            "AngelList": f"https://angel.co/{username}",
            "Behance": f"https://www.behance.net/{username}",
            "Dribbble": f"https://dribbble.com/{username}",
            "About.me": f"https://about.me/{username}",
            "Gravatar": f"https://gravatar.com/{username}",
            "ResearchGate": f"https://www.researchgate.net/profile/{username}",
            "Academia": f"https://{username}.academia.edu/",
            
            # === MUSIC PLATFORMS ===
            "Spotify": f"https://open.spotify.com/user/{username}",
            "SoundCloud": f"https://soundcloud.com/{username}",
            "Bandcamp": f"https://{username}.bandcamp.com",
            "Last.fm": f"https://www.last.fm/user/{username}",
            "Mixcloud": f"https://www.mixcloud.com/{username}",
            "Audiomack": f"https://audiomack.com/{username}",
            
            # === FORUMS & COMMUNITIES ===
            "HackerNews": f"https://news.ycombinator.com/user?id={username}",
            "ProductHunt": f"https://www.producthunt.com/@{username}",
            "Keybase": f"https://keybase.io/{username}",
            "Patreon": f"https://www.patreon.com/{username}",
            "Ko-fi": f"https://ko-fi.com/{username}",
            "BuyMeACoffee": f"https://www.buymeacoffee.com/{username}",
            
            # === INTERNATIONAL SOCIAL MEDIA ===
            "VK": f"https://vk.com/{username}",
            "OK.ru": f"https://ok.ru/{username}",
            "Weibo": f"https://weibo.com/{username}",
            "QQ": f"https://user.qzone.qq.com/{username}",
            "Douban": f"https://www.douban.com/people/{username}",
            
            # === BUSINESS & E-COMMERCE ===
            "Etsy": f"https://www.etsy.com/shop/{username}",
            "eBay": f"https://www.ebay.com/usr/{username}",
            "Fiverr": f"https://www.fiverr.com/{username}",
            "Upwork": f"https://www.upwork.com/freelancers/~{username}",
            "Freelancer": f"https://www.freelancer.com/u/{username}",
            "PeoplePerHour": f"https://www.peopleperhour.com/freelancer/{username}",
            
            # === BLOGGING PLATFORMS ===
            "WordPress": f"https://{username}.wordpress.com",
            "Blogger": f"https://{username}.blogspot.com",
            "Medium": f"https://medium.com/@{username}",
            "Ghost": f"https://{username}.ghost.io",
            "Substack": f"https://{username}.substack.com",
            
            # === PHOTOGRAPHY ===
            "Flickr": f"https://www.flickr.com/people/{username}",
            "500px": f"https://500px.com/p/{username}",
            "Unsplash": f"https://unsplash.com/@{username}",
            "VSCO": f"https://vsco.co/{username}",
            "DeviantArt": f"https://www.deviantart.com/{username}",
            "ArtStation": f"https://www.artstation.com/{username}",
            
            # === MESSAGING & CHAT ===
            "Telegram": f"https://t.me/{username}",
            "Signal": f"https://signal.me/#p/{username}",
            "Viber": f"https://viber.com/{username}",
            "Line": f"https://line.me/ti/p/~{username}",
            "Kik": f"https://kik.me/{username}",
            
            # === DATING & ADULT PLATFORMS ===
            "OnlyFans": f"https://onlyfans.com/{username}",
            "Pornhub": f"https://www.pornhub.com/users/{username}",
            "Chaturbate": f"https://chaturbate.com/{username}",
            "Fansly": f"https://fansly.com/{username}",
            "ManyVids": f"https://www.manyvids.com/Profile/{username}",
            "Clips4Sale": f"https://www.clips4sale.com/studio/{username}",
            "Tinder": f"https://tinder.com/@{username}",
            "Bumble": f"https://bumble.com/{username}",
            "Badoo": f"https://badoo.com/{username}",
            "Match": f"https://www.match.com/profile/{username}",
            "OkCupid": f"https://www.okcupid.com/profile/{username}",
            "Plenty of Fish": f"https://www.pof.com/{username}",
            "Adult Friend Finder": f"https://adultfriendfinder.com/profile/{username}",
            
            # === MONEY & PAYMENT ===
            "Linktree": f"https://linktr.ee/{username}",
            "Cash App": f"https://cash.app/${username}",
            "Venmo": f"https://venmo.com/{username}",
            "PayPal": f"https://www.paypal.me/{username}",
            "Bitcoin": f"https://www.blockchain.com/btc/address/{username}",
            
            # === KNOWLEDGE & LEARNING ===
            "Quora": f"https://www.quora.com/profile/{username}",
            "Duolingo": f"https://www.duolingo.com/profile/{username}",
            "Coursera": f"https://www.coursera.org/user/{username}",
            "Udemy": f"https://www.udemy.com/user/{username}",
            
            # === ENTERTAINMENT & MEDIA ===
            "Goodreads": f"https://www.goodreads.com/{username}",
            "Letterboxd": f"https://letterboxd.com/{username}",
            "MyAnimeList": f"https://myanimelist.net/profile/{username}",
            "AniList": f"https://anilist.co/user/{username}",
            "Crunchyroll": f"https://www.crunchyroll.com/user/{username}",
            "Wattpad": f"https://www.wattpad.com/user/{username}",
            "Archive of Our Own": f"https://archiveofourown.org/users/{username}",
            
            # === SPORTS & FITNESS ===
            "Strava": f"https://www.strava.com/athletes/{username}",
            "Chess.com": f"https://www.chess.com/member/{username}",
            "Lichess": f"https://lichess.org/@/{username}",
            "Untappd": f"https://untappd.com/user/{username}",
            "MyFitnessPal": f"https://www.myfitnesspal.com/profile/{username}",
        }
        
        return platforms

    def print_banner(self):
        """Display tool banner"""
        banner = f"""
{Fore.CYAN}╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║            {Fore.RED}WhoisUser - OSINT Investigation Tool{Fore.CYAN}                ║
║                                                               ║
║         {Fore.YELLOW}Professional Username Enumeration & Profiling{Fore.CYAN}         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝{Style.RESET_ALL}

{Fore.GREEN}[+] Target Username:{Fore.WHITE} {self.username}
{Fore.GREEN}[+] Investigation ID:{Fore.WHITE} {self.timestamp}
{Fore.GREEN}[+] Output Directory:{Fore.WHITE} {self.output_dir}
{Fore.GREEN}[+] Total Platforms:{Fore.WHITE} {len(self.platforms)}
{Fore.GREEN}[+] Available OSINT Tools:{Fore.WHITE} {len(self.available_tools)}
{Style.RESET_ALL}
"""
        print(banner)
        
        if self.available_tools:
            print(f"{Fore.CYAN}[*] Detected OSINT Tools:{Style.RESET_ALL}")
            for tool in self.available_tools:
                print(f"    {Fore.GREEN}✓{Fore.WHITE} {tool}{Style.RESET_ALL}")
            print()

    def run_sherlock(self):
        """Run Sherlock tool for username enumeration"""
        if 'sherlock' not in self.available_tools:
            return None
        
        print(f"\n{Fore.YELLOW}[*] Running Sherlock for enhanced username search...{Style.RESET_ALL}\n")
        
        try:
            output_file = f"{self.osint_dir}/sherlock_results.txt"
            cmd = ['sherlock', self.username, '--output', output_file, '--timeout', '10']
            
            process = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if os.path.exists(output_file):
                with open(output_file, 'r') as f:
                    content = f.read()
                    # Parse Sherlock results
                    for line in content.split('\n'):
                        if line.startswith('[+]'):
                            parts = line.split(': ')
                            if len(parts) >= 2:
                                url = parts[1].strip()
                                platform = parts[0].replace('[+]', '').strip()
                                self.sherlock_results.append({
                                    'platform': platform,
                                    'url': url,
                                    'source': 'sherlock'
                                })
                
                print(f"{Fore.GREEN}[✓] Sherlock completed: {len(self.sherlock_results)} additional profiles found{Style.RESET_ALL}")
                return output_file
        except Exception as e:
            print(f"{Fore.RED}[✗] Sherlock error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def run_maigret(self):
        """Run Maigret tool for username enumeration"""
        if 'maigret' not in self.available_tools:
            return None
        
        print(f"\n{Fore.YELLOW}[*] Running Maigret for deep OSINT search...{Style.RESET_ALL}\n")
        
        try:
            output_dir = f"{self.osint_dir}/maigret"
            cmd = ['maigret', self.username, '--folderoutput', output_dir, '--timeout', '10']
            
            process = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            print(f"{Fore.GREEN}[✓] Maigret completed - results saved to {output_dir}{Style.RESET_ALL}")
            return output_dir
        except Exception as e:
            print(f"{Fore.RED}[✗] Maigret error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def run_holehe(self):
        """Run Holehe to check email-based accounts"""
        if 'holehe' not in self.available_tools:
            return None
        
        print(f"\n{Fore.YELLOW}[*] Running Holehe for email enumeration...{Style.RESET_ALL}\n")
        
        try:
            # Try username as email
            email_variants = [
                f"{self.username}@gmail.com",
                f"{self.username}@yahoo.com",
                f"{self.username}@outlook.com",
            ]
            
            results = []
            for email in email_variants:
                output_file = f"{self.osint_dir}/holehe_{email.replace('@', '_at_')}.txt"
                cmd = ['holehe', email]
                
                process = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
                
                with open(output_file, 'w') as f:
                    f.write(process.stdout)
                
                results.append(output_file)
            
            print(f"{Fore.GREEN}[✓] Holehe completed - checked {len(email_variants)} email variants{Style.RESET_ALL}")
            return results
        except Exception as e:
            print(f"{Fore.RED}[✗] Holehe error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def check_url(self, platform_name, url):
        """Check if profile exists on platform"""
        try:
            response = requests.get(
                url, 
                headers=self.headers, 
                timeout=10, 
                allow_redirects=True,
                verify=True
            )
            
            if response.status_code == 200:
                content_lower = response.text.lower()
                
                not_found_patterns = [
                    "page not found",
                    "user not found",
                    "doesn't exist",
                    "not available",
                    "profile not found",
                    "sorry, this page isn't available",
                    "the page you requested was not found",
                    "this account doesn't exist",
                    "no such user",
                    "404 error"
                ]
                
                if any(pattern in content_lower for pattern in not_found_patterns):
                    return None
                
                print(f"{Fore.GREEN}[✓] {Fore.WHITE}{platform_name:<25} {Fore.CYAN}→ {url}{Style.RESET_ALL}")
                return {
                    'platform': platform_name,
                    'url': url,
                    'status_code': response.status_code,
                    'found_at': datetime.now().isoformat(),
                    'source': 'whoisuser'
                }
            
        except requests.exceptions.Timeout:
            pass
        except Exception:
            pass
        
        return None

    def scan_platforms(self):
        """Scan all platforms using concurrent threads"""
        print(f"\n{Fore.YELLOW}[*] Starting scan across {len(self.platforms)} platforms...{Style.RESET_ALL}\n")
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=25) as executor:
            future_to_platform = {
                executor.submit(self.check_url, platform, url): platform 
                for platform, url in self.platforms.items()
            }
            
            for future in concurrent.futures.as_completed(future_to_platform):
                result = future.result()
                if result:
                    self.found_profiles.append(result)

    def take_screenshot(self, url, platform_name):
        """Capture screenshot of profile page"""
        try:
            from selenium import webdriver
            from selenium.webdriver.chrome.options import Options
            from selenium.webdriver.chrome.service import Service
            from webdriver_manager.chrome import ChromeDriverManager
            
            chrome_options = Options()
            chrome_options.add_argument('--headless')
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument('--window-size=1920,1080')
            chrome_options.add_argument('--disable-blink-features=AutomationControlled')
            chrome_options.add_argument(f'user-agent={self.headers["User-Agent"]}')
            
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            
            driver.get(url)
            time.sleep(3)
            
            screenshot_path = f"{self.images_dir}/{platform_name.replace('/', '_').replace(' ', '_')}.png"
            driver.save_screenshot(screenshot_path)
            driver.quit()
            
            return screenshot_path
            
        except Exception as e:
            return None

    def capture_screenshots(self):
        """Capture screenshots of all found profiles"""
        if not self.found_profiles:
            return
            
        print(f"\n{Fore.YELLOW}[*] Capturing screenshots of {len(self.found_profiles)} found profiles...{Style.RESET_ALL}\n")
        
        for profile in self.found_profiles:
            if profile.get('source') == 'whoisuser':  # Only screenshot our direct finds
                print(f"{Fore.CYAN}[→] Capturing: {profile['platform']}{Style.RESET_ALL}")
                screenshot_path = self.take_screenshot(profile['url'], profile['platform'])
                if screenshot_path:
                    profile['screenshot'] = screenshot_path

    def generate_report(self):
        """Generate comprehensive investigation reports"""
        # Merge results from all sources
        all_profiles = self.found_profiles + self.sherlock_results
        
        # Remove duplicates
        seen_urls = set()
        unique_profiles = []
        for profile in all_profiles:
            if profile['url'] not in seen_urls:
                seen_urls.add(profile['url'])
                unique_profiles.append(profile)
        
        # TXT Report
        txt_report_path = f"{self.output_dir}/FULL_REPORT.txt"
        with open(txt_report_path, 'w', encoding='utf-8') as f:
            f.write("="*80 + "\n")
            f.write("WHOISUSER - COMPREHENSIVE OSINT INVESTIGATION REPORT\n")
            f.write("="*80 + "\n\n")
            f.write(f"Investigation Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"Target Username: {self.username}\n")
            f.write(f"Investigation ID: {self.timestamp}\n")
            f.write(f"Investigator: Anubhav (Cybersecurity & Cyber Forensic Researcher)\n")
            f.write(f"Total Platforms Scanned: {len(self.platforms)}\n")
            f.write(f"Profiles Found (Direct): {len(self.found_profiles)}\n")
            f.write(f"Profiles Found (Sherlock): {len(self.sherlock_results)}\n")
            f.write(f"Total Unique Profiles: {len(unique_profiles)}\n")
            f.write(f"Available OSINT Tools: {', '.join(self.available_tools.keys())}\n")
            f.write("\n" + "="*80 + "\n")
            f.write("DISCOVERED PROFILES\n")
            f.write("="*80 + "\n\n")
            
            for i, profile in enumerate(unique_profiles, 1):
                f.write(f"{i}. Platform: {profile['platform']}\n")
                f.write(f"   URL: {profile['url']}\n")
                f.write(f"   Source: {profile.get('source', 'unknown')}\n")
                if 'status_code' in profile:
                    f.write(f"   Status: Active (HTTP {profile['status_code']})\n")
                if 'found_at' in profile:
                    f.write(f"   Discovered At: {profile['found_at']}\n")
                if 'screenshot' in profile:
                    f.write(f"   Evidence: {profile['screenshot']}\n")
                f.write("\n")
            
            f.write("="*80 + "\n")
            f.write("END OF REPORT\n")
            f.write("="*80 + "\n")
        
        # JSON Report
        json_report_path = f"{self.output_dir}/report.json"
        with open(json_report_path, 'w', encoding='utf-8') as f:
            json.dump({
                'investigation': {
                    'username': self.username,
                    'timestamp': self.timestamp,
                    'date': datetime.now().isoformat(),
                    'investigator': 'Anubhav',
                    'total_platforms': len(self.platforms),
                    'profiles_found_direct': len(self.found_profiles),
                    'profiles_found_sherlock': len(self.sherlock_results),
                    'total_unique_profiles': len(unique_profiles),
                    'osint_tools_used': list(self.available_tools.keys())
                },
                'profiles': unique_profiles
            }, f, indent=4)
        
        # URLs List
        urls_path = f"{self.output_dir}/all_urls.txt"
        with open(urls_path, 'w', encoding='utf-8') as f:
            for profile in unique_profiles:
                f.write(f"{profile['url']}\n")

    def print_summary(self):
        """Print investigation summary"""
        all_profiles = len(self.found_profiles) + len(self.sherlock_results)
        
        print(f"\n{Fore.CYAN}{'='*80}{Style.RESET_ALL}")
        print(f"{Fore.GREEN}INVESTIGATION COMPLETE!{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'='*80}{Style.RESET_ALL}\n")
        
        print(f"{Fore.YELLOW}Summary:{Style.RESET_ALL}")
        print(f"  • Total Platforms Scanned: {Fore.WHITE}{len(self.platforms)}{Style.RESET_ALL}")
        print(f"  • Profiles Found (Direct): {Fore.GREEN}{len(self.found_profiles)}{Style.RESET_ALL}")
        if self.sherlock_results:
            print(f"  • Profiles Found (Sherlock): {Fore.GREEN}{len(self.sherlock_results)}{Style.RESET_ALL}")
        print(f"  • Total Profiles: {Fore.CYAN}{all_profiles}{Style.RESET_ALL}")
        print(f"  • OSINT Tools Used: {Fore.WHITE}{len(self.available_tools)}{Style.RESET_ALL}\n")
        
        print(f"{Fore.YELLOW}Output Files:{Style.RESET_ALL}")
        print(f"  • Full Report: {Fore.WHITE}{self.output_dir}/FULL_REPORT.txt{Style.RESET_ALL}")
        print(f"  • JSON Report: {Fore.WHITE}{self.output_dir}/report.json{Style.RESET_ALL}")
        print(f"  • URLs List: {Fore.WHITE}{self.output_dir}/all_urls.txt{Style.RESET_ALL}")
        print(f"  • Screenshots: {Fore.WHITE}{self.images_dir}/{Style.RESET_ALL}")
        print(f"  • OSINT Results: {Fore.WHITE}{self.osint_dir}/{Style.RESET_ALL}\n")

    def run(self, capture_screenshots=True, use_osint_tools=True):
        """Execute the investigation"""
        self.print_banner()
        
        # Run external OSINT tools first
        if use_osint_tools:
            self.run_sherlock()
            self.run_maigret()
            self.run_holehe()
        
        # Run our custom scanner
        self.scan_platforms()
        
        # Capture screenshots
        if capture_screenshots and self.found_profiles:
            try:
                self.capture_screenshots()
            except ImportError:
                print(f"\n{Fore.YELLOW}[!] Selenium not installed. Skipping screenshots.{Style.RESET_ALL}\n")
        
        self.generate_report()
        self.print_summary()

def main():
    if len(sys.argv) < 2:
        print(f"{Fore.RED}Usage: whoisuser <username> [options]{Style.RESET_ALL}")
        print(f"\n{Fore.YELLOW}Options:{Style.RESET_ALL}")
        print(f"  --no-screenshots    Skip screenshot capture (faster)")
        print(f"  --no-osint-tools    Skip external OSINT tools (Sherlock, Maigret, etc.)")
        print(f"\n{Fore.YELLOW}Examples:{Style.RESET_ALL}")
        print(f"  whoisuser johndoe")
        print(f"  whoisuser johndoe --no-screenshots")
        print(f"  whoisuser johndoe --no-osint-tools")
        sys.exit(1)
    
    username = sys.argv[1]
    capture_screenshots = '--no-screenshots' not in sys.argv
    use_osint_tools = '--no-osint-tools' not in sys.argv
    
    investigator = WhoisUser(username)
    investigator.run(capture_screenshots=capture_screenshots, use_osint_tools=use_osint_tools)

if __name__ == "__main__":
    main()
