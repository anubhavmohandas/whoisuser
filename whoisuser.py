#!/usr/bin/env python3
"""
WhoisUser - Professional Username OSINT & Forensic Investigation Tool
Author: Anubhav
Description: Automated username enumeration with integrated OSINT tools
Version: 2.5 (Enhanced & Merged)
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
from urllib.parse import urlparse
import logging

# Initialize colorama
init(autoreset=True)

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.FileHandler('whoisuser.log'), logging.StreamHandler()]
)

class WhoisUser:
    def __init__(self, username):
        self.username = username
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.output_dir = f"investigations/{username}_{self.timestamp}"
        self.images_dir = f"{self.output_dir}/screenshots"
        self.osint_dir = f"{self.output_dir}/osint_results"
        self.found_profiles = []
        self.sherlock_results = []
        self.failed_checks = []
        
        # Create output directories
        Path(self.output_dir).mkdir(parents=True, exist_ok=True)
        Path(self.images_dir).mkdir(parents=True, exist_ok=True)
        Path(self.osint_dir).mkdir(parents=True, exist_ok=True)
        
        # Check for available OSINT tools
        self.available_tools = self.check_osint_tools()
        
        # Comprehensive platform list
        self.platforms = self.get_all_platforms()
        
        # Use session for connection pooling
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        })
        
        # Rate limiting
        self.request_delay = 0.3  # seconds between requests
        self.last_request_time = {}

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
            "Instagram": {
                "url": f"https://www.instagram.com/{username}/",
                "check_type": "standard"
            },
            "Twitter/X": {
                "url": f"https://twitter.com/{username}",
                "check_type": "standard"
            },
            "Facebook": {
                "url": f"https://www.facebook.com/{username}",
                "check_type": "redirect"
            },
            "LinkedIn": {
                "url": f"https://www.linkedin.com/in/{username}",
                "check_type": "standard"
            },
            "TikTok": {
                "url": f"https://www.tiktok.com/@{username}",
                "check_type": "standard"
            },
            "Snapchat": {
                "url": f"https://www.snapchat.com/add/{username}",
                "check_type": "standard"
            },
            "Reddit": {
                "url": f"https://www.reddit.com/user/{username}",
                "check_type": "json",
                "api_url": f"https://www.reddit.com/user/{username}/about.json"
            },
            "Pinterest": {
                "url": f"https://www.pinterest.com/{username}",
                "check_type": "standard"
            },
            "Tumblr": {
                "url": f"https://{username}.tumblr.com",
                "check_type": "standard"
            },
            "Mastodon": {
                "url": f"https://mastodon.social/@{username}",
                "check_type": "standard"
            },
            
            # === VIDEO PLATFORMS ===
            "YouTube": {
                "url": f"https://www.youtube.com/@{username}",
                "check_type": "standard"
            },
            "Vimeo": {
                "url": f"https://vimeo.com/{username}",
                "check_type": "standard"
            },
            "Dailymotion": {
                "url": f"https://www.dailymotion.com/{username}",
                "check_type": "standard"
            },
            "Twitch": {
                "url": f"https://www.twitch.tv/{username}",
                "check_type": "standard"
            },
            "Rumble": {
                "url": f"https://rumble.com/user/{username}",
                "check_type": "standard"
            },
            "BitChute": {
                "url": f"https://www.bitchute.com/channel/{username}",
                "check_type": "standard"
            },
            
            # === DEVELOPER PLATFORMS ===
            "GitHub": {
                "url": f"https://github.com/{username}",
                "check_type": "standard",
                "api_url": f"https://api.github.com/users/{username}"
            },
            "GitLab": {
                "url": f"https://gitlab.com/{username}",
                "check_type": "standard"
            },
            "Bitbucket": {
                "url": f"https://bitbucket.org/{username}",
                "check_type": "standard"
            },
            "StackOverflow": {
                "url": f"https://stackoverflow.com/users/{username}",
                "check_type": "search"
            },
            "HackerRank": {
                "url": f"https://www.hackerrank.com/{username}",
                "check_type": "standard"
            },
            "LeetCode": {
                "url": f"https://leetcode.com/{username}",
                "check_type": "standard"
            },
            "CodePen": {
                "url": f"https://codepen.io/{username}",
                "check_type": "standard"
            },
            "Repl.it": {
                "url": f"https://replit.com/@{username}",
                "check_type": "standard"
            },
            "Dev.to": {
                "url": f"https://dev.to/{username}",
                "check_type": "standard"
            },
            "Kaggle": {
                "url": f"https://www.kaggle.com/{username}",
                "check_type": "standard"
            },
            "HackerOne": {
                "url": f"https://hackerone.com/{username}",
                "check_type": "standard"
            },
            "CodeChef": {
                "url": f"https://www.codechef.com/users/{username}",
                "check_type": "standard"
            },
            
            # === GAMING PLATFORMS ===
            "Steam": {
                "url": f"https://steamcommunity.com/id/{username}",
                "check_type": "standard"
            },
            "Xbox": {
                "url": f"https://xboxgamertag.com/search/{username}",
                "check_type": "standard"
            },
            "PlayStation": {
                "url": f"https://psnprofiles.com/{username}",
                "check_type": "standard"
            },
            "Discord": {
                "url": f"https://discord.com/users/{username}",
                "check_type": "standard"
            },
            "Roblox": {
                "url": f"https://www.roblox.com/users/profile?username={username}",
                "check_type": "standard"
            },
            "Epic Games": {
                "url": f"https://www.epicgames.com/site/en-US/profile/{username}",
                "check_type": "standard"
            },
            "Fortnite": {
                "url": f"https://fortnitetracker.com/profile/all/{username}",
                "check_type": "standard"
            },
            "Minecraft": {
                "url": f"https://namemc.com/profile/{username}",
                "check_type": "standard"
            },
            
            # === PROFESSIONAL NETWORKS ===
            "AngelList": {
                "url": f"https://angel.co/{username}",
                "check_type": "standard"
            },
            "Behance": {
                "url": f"https://www.behance.net/{username}",
                "check_type": "standard"
            },
            "Dribbble": {
                "url": f"https://dribbble.com/{username}",
                "check_type": "standard"
            },
            "About.me": {
                "url": f"https://about.me/{username}",
                "check_type": "standard"
            },
            "Gravatar": {
                "url": f"https://gravatar.com/{username}",
                "check_type": "standard"
            },
            "ResearchGate": {
                "url": f"https://www.researchgate.net/profile/{username}",
                "check_type": "standard"
            },
            "Academia": {
                "url": f"https://{username}.academia.edu/",
                "check_type": "standard"
            },
            
            # === MUSIC PLATFORMS ===
            "Spotify": {
                "url": f"https://open.spotify.com/user/{username}",
                "check_type": "standard"
            },
            "SoundCloud": {
                "url": f"https://soundcloud.com/{username}",
                "check_type": "standard"
            },
            "Bandcamp": {
                "url": f"https://{username}.bandcamp.com",
                "check_type": "standard"
            },
            "Last.fm": {
                "url": f"https://www.last.fm/user/{username}",
                "check_type": "standard"
            },
            "Mixcloud": {
                "url": f"https://www.mixcloud.com/{username}",
                "check_type": "standard"
            },
            "Audiomack": {
                "url": f"https://audiomack.com/{username}",
                "check_type": "standard"
            },
            
            # === FORUMS & COMMUNITIES ===
            "HackerNews": {
                "url": f"https://news.ycombinator.com/user?id={username}",
                "check_type": "standard"
            },
            "ProductHunt": {
                "url": f"https://www.producthunt.com/@{username}",
                "check_type": "standard"
            },
            "Keybase": {
                "url": f"https://keybase.io/{username}",
                "check_type": "standard"
            },
            "Patreon": {
                "url": f"https://www.patreon.com/{username}",
                "check_type": "standard"
            },
            "Ko-fi": {
                "url": f"https://ko-fi.com/{username}",
                "check_type": "standard"
            },
            "BuyMeACoffee": {
                "url": f"https://www.buymeacoffee.com/{username}",
                "check_type": "standard"
            },
            
            # === INTERNATIONAL SOCIAL MEDIA ===
            "VK": {
                "url": f"https://vk.com/{username}",
                "check_type": "standard"
            },
            "OK.ru": {
                "url": f"https://ok.ru/{username}",
                "check_type": "standard"
            },
            "Weibo": {
                "url": f"https://weibo.com/{username}",
                "check_type": "standard"
            },
            "QQ": {
                "url": f"https://user.qzone.qq.com/{username}",
                "check_type": "standard"
            },
            "Douban": {
                "url": f"https://www.douban.com/people/{username}",
                "check_type": "standard"
            },
            
            # === BUSINESS & E-COMMERCE ===
            "Etsy": {
                "url": f"https://www.etsy.com/shop/{username}",
                "check_type": "standard"
            },
            "eBay": {
                "url": f"https://www.ebay.com/usr/{username}",
                "check_type": "standard"
            },
            "Fiverr": {
                "url": f"https://www.fiverr.com/{username}",
                "check_type": "standard"
            },
            "Upwork": {
                "url": f"https://www.upwork.com/freelancers/~{username}",
                "check_type": "standard"
            },
            "Freelancer": {
                "url": f"https://www.freelancer.com/u/{username}",
                "check_type": "standard"
            },
            "PeoplePerHour": {
                "url": f"https://www.peopleperhour.com/freelancer/{username}",
                "check_type": "standard"
            },
            
            # === BLOGGING PLATFORMS ===
            "WordPress": {
                "url": f"https://{username}.wordpress.com",
                "check_type": "standard"
            },
            "Blogger": {
                "url": f"https://{username}.blogspot.com",
                "check_type": "standard"
            },
            "Medium": {
                "url": f"https://medium.com/@{username}",
                "check_type": "standard"
            },
            "Ghost": {
                "url": f"https://{username}.ghost.io",
                "check_type": "standard"
            },
            "Substack": {
                "url": f"https://{username}.substack.com",
                "check_type": "standard"
            },
            
            # === PHOTOGRAPHY ===
            "Flickr": {
                "url": f"https://www.flickr.com/people/{username}",
                "check_type": "standard"
            },
            "500px": {
                "url": f"https://500px.com/p/{username}",
                "check_type": "standard"
            },
            "Unsplash": {
                "url": f"https://unsplash.com/@{username}",
                "check_type": "standard"
            },
            "VSCO": {
                "url": f"https://vsco.co/{username}",
                "check_type": "standard"
            },
            "DeviantArt": {
                "url": f"https://www.deviantart.com/{username}",
                "check_type": "standard"
            },
            "ArtStation": {
                "url": f"https://www.artstation.com/{username}",
                "check_type": "standard"
            },
            
            # === MESSAGING & CHAT ===
            "Telegram": {
                "url": f"https://t.me/{username}",
                "check_type": "standard"
            },
            "Signal": {
                "url": f"https://signal.me/#p/{username}",
                "check_type": "standard"
            },
            "Viber": {
                "url": f"https://viber.com/{username}",
                "check_type": "standard"
            },
            "Line": {
                "url": f"https://line.me/ti/p/~{username}",
                "check_type": "standard"
            },
            "Kik": {
                "url": f"https://kik.me/{username}",
                "check_type": "standard"
            },
            
            # === DATING & ADULT PLATFORMS ===
            "OnlyFans": {
                "url": f"https://onlyfans.com/{username}",
                "check_type": "standard"
            },
            "Pornhub": {
                "url": f"https://www.pornhub.com/users/{username}",
                "check_type": "standard"
            },
            "Chaturbate": {
                "url": f"https://chaturbate.com/{username}",
                "check_type": "standard"
            },
            "Fansly": {
                "url": f"https://fansly.com/{username}",
                "check_type": "standard"
            },
            "ManyVids": {
                "url": f"https://www.manyvids.com/Profile/{username}",
                "check_type": "standard"
            },
            "Clips4Sale": {
                "url": f"https://www.clips4sale.com/studio/{username}",
                "check_type": "standard"
            },
            "Tinder": {
                "url": f"https://tinder.com/@{username}",
                "check_type": "standard"
            },
            "Bumble": {
                "url": f"https://bumble.com/{username}",
                "check_type": "standard"
            },
            "Badoo": {
                "url": f"https://badoo.com/{username}",
                "check_type": "standard"
            },
            "Match": {
                "url": f"https://www.match.com/profile/{username}",
                "check_type": "standard"
            },
            "OkCupid": {
                "url": f"https://www.okcupid.com/profile/{username}",
                "check_type": "standard"
            },
            "Plenty of Fish": {
                "url": f"https://www.pof.com/{username}",
                "check_type": "standard"
            },
            "Adult Friend Finder": {
                "url": f"https://adultfriendfinder.com/profile/{username}",
                "check_type": "standard"
            },
            
            # === MONEY & PAYMENT ===
            "Linktree": {
                "url": f"https://linktr.ee/{username}",
                "check_type": "standard"
            },
            "Cash App": {
                "url": f"https://cash.app/${username}",
                "check_type": "standard"
            },
            "Venmo": {
                "url": f"https://venmo.com/{username}",
                "check_type": "standard"
            },
            "PayPal": {
                "url": f"https://www.paypal.me/{username}",
                "check_type": "standard"
            },
            "Bitcoin": {
                "url": f"https://www.blockchain.com/btc/address/{username}",
                "check_type": "standard"
            },
            
            # === KNOWLEDGE & LEARNING ===
            "Quora": {
                "url": f"https://www.quora.com/profile/{username}",
                "check_type": "standard"
            },
            "Duolingo": {
                "url": f"https://www.duolingo.com/profile/{username}",
                "check_type": "standard"
            },
            "Coursera": {
                "url": f"https://www.coursera.org/user/{username}",
                "check_type": "standard"
            },
            "Udemy": {
                "url": f"https://www.udemy.com/user/{username}",
                "check_type": "standard"
            },
            
            # === ENTERTAINMENT & MEDIA ===
            "Goodreads": {
                "url": f"https://www.goodreads.com/{username}",
                "check_type": "standard"
            },
            "Letterboxd": {
                "url": f"https://letterboxd.com/{username}",
                "check_type": "standard"
            },
            "MyAnimeList": {
                "url": f"https://myanimelist.net/profile/{username}",
                "check_type": "standard"
            },
            "AniList": {
                "url": f"https://anilist.co/user/{username}",
                "check_type": "standard"
            },
            "Crunchyroll": {
                "url": f"https://www.crunchyroll.com/user/{username}",
                "check_type": "standard"
            },
            "Wattpad": {
                "url": f"https://www.wattpad.com/user/{username}",
                "check_type": "standard"
            },
            "Archive of Our Own": {
                "url": f"https://archiveofourown.org/users/{username}",
                "check_type": "standard"
            },
            
            # === SPORTS & FITNESS ===
            "Strava": {
                "url": f"https://www.strava.com/athletes/{username}",
                "check_type": "standard"
            },
            "Chess.com": {
                "url": f"https://www.chess.com/member/{username}",
                "check_type": "standard"
            },
            "Lichess": {
                "url": f"https://lichess.org/@/{username}",
                "check_type": "standard"
            },
            "Untappd": {
                "url": f"https://untappd.com/user/{username}",
                "check_type": "standard"
            },
            "MyFitnessPal": {
                "url": f"https://www.myfitnesspal.com/profile/{username}",
                "check_type": "standard"
            },
        }
        
        return platforms

    def rate_limit_domain(self, url):
        """Implement per-domain rate limiting"""
        domain = urlparse(url).netloc
        current_time = time.time()
        
        if domain in self.last_request_time:
            time_since_last = current_time - self.last_request_time[domain]
            if time_since_last < self.request_delay:
                time.sleep(self.request_delay - time_since_last)
        
        self.last_request_time[domain] = time.time()

    def check_json_api(self, platform_name, platform_data):
        """Check platforms with JSON API endpoints"""
        try:
            api_url = platform_data.get("api_url")
            self.rate_limit_domain(api_url)
            response = self.session.get(api_url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data and 'error' not in data:
                    print(f"{Fore.GREEN}[✓] {Fore.WHITE}{platform_name:<25} {Fore.CYAN}→ {platform_data['url']}{Style.RESET_ALL}")
                    return {
                        'platform': platform_name,
                        'url': platform_data['url'],
                        'api_url': api_url,
                        'found_at': datetime.now().isoformat(),
                        'source': 'whoisuser_api',
                        'verified': True
                    }
        except Exception as e:
            logging.debug(f"API check failed for {platform_name}: {str(e)}")
        
        return None

    def check_url(self, platform_name, platform_data):
        """Check if profile exists on platform with improved detection"""
        if isinstance(platform_data, str):
            url = platform_data
            check_type = "standard"
        else:
            url = platform_data.get("url")
            check_type = platform_data.get("check_type", "standard")
        
        try:
            # Use JSON API if available
            if check_type == "json" and "api_url" in platform_data:
                result = self.check_json_api(platform_name, platform_data)
                if result:
                    return result
            
            # Rate limiting
            self.rate_limit_domain(url)
            
            # Standard HTTP check
            response = self.session.get(
                url, 
                timeout=10, 
                allow_redirects=True
            )
            
            # Check status code
            if response.status_code == 404:
                return None
            
            if response.status_code != 200:
                self.failed_checks.append({
                    'platform': platform_name,
                    'url': url,
                    'status': response.status_code,
                    'reason': 'non-200 status'
                })
                return None
            
            # Check for redirects to login/homepage
            if any(x in response.url.lower() for x in ['login', 'signup', 'signin', 'register']):
                return None
            
            # Check content
            content_lower = response.text.lower()
            
            # Expanded not-found patterns
            not_found_patterns = [
                "page not found", "user not found", "doesn't exist",
                "not available", "profile not found",
                "sorry, this page isn't available",
                "the page you requested was not found",
                "this account doesn't exist", "no such user",
                "404 error", "404 not found", "account suspended",
                "user does not exist", "profile unavailable",
                "page doesn't exist", "couldn't find",
                "account not found"
            ]
            
            if any(pattern in content_lower for pattern in not_found_patterns):
                return None
            
            # Check minimum content length
            if len(response.text.strip()) < 200:
                return None
            
            # Success
            print(f"{Fore.GREEN}[✓] {Fore.WHITE}{platform_name:<25} {Fore.CYAN}→ {url}{Style.RESET_ALL}")
            return {
                'platform': platform_name,
                'url': url,
                'status_code': response.status_code,
                'found_at': datetime.now().isoformat(),
                'source': 'whoisuser',
                'content_length': len(response.text)
            }
            
        except requests.exceptions.Timeout:
            logging.warning(f"Timeout checking {platform_name}")
            self.failed_checks.append({
                'platform': platform_name,
                'url': url,
                'reason': 'timeout'
            })
        except requests.exceptions.ConnectionError:
            logging.warning(f"Connection error checking {platform_name}")
        except Exception as e:
            logging.error(f"Error checking {platform_name}: {str(e)}")
        
        return None

    def print_banner(self):
        """Display tool banner"""
        banner = f"""
{Fore.CYAN}╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║            {Fore.RED}WhoisUser - OSINT Investigation Tool{Fore.CYAN}                ║
║                                                               ║
║         {Fore.YELLOW}Professional Username Enumeration & Profiling{Fore.CYAN}         ║
║                 {Fore.GREEN}Version 2.5 - Enhanced & Merged{Fore.CYAN}                ║
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
            cmd = ['sherlock', self.username, '--output', output_file, '--timeout', '10', '--print-found']
            
            process = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if os.path.exists(output_file):
                with open(output_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    for line in content.split('\n'):
                        if 'http' in line.lower():
                            parts = line.split('http')
                            if len(parts) >= 2:
                                url = 'http' + parts[1].strip()
                                domain = urlparse(url).netloc.replace('www.', '').split('.')[0].title()
                                self.sherlock_results.append({
                                    'platform': f"{domain} (Sherlock)",
                                    'url': url,
                                    'source': 'sherlock'
                                })
                
                print(f"{Fore.GREEN}[✓] Sherlock completed: {len(self.sherlock_results)} additional profiles found{Style.RESET_ALL}")
                return output_file
        except subprocess.TimeoutExpired:
            print(f"{Fore.RED}[✗] Sherlock timed out{Style.RESET_ALL}")
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
        except subprocess.TimeoutExpired:
            print(f"{Fore.RED}[✗] Maigret timed out{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}[✗] Maigret error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def run_holehe(self):
        """Run Holehe to check email-based accounts"""
        if 'holehe' not in self.available_tools:
            return None
        
        print(f"\n{Fore.YELLOW}[*] Running Holehe for email enumeration...{Style.RESET_ALL}\n")
        
        try:
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
        except subprocess.TimeoutExpired:
            print(f"{Fore.RED}[✗] Holehe timed out{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}[✗] Holehe error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def run_blackbird(self):
        """Run Blackbird for fast username search"""
        if 'blackbird' not in self.available_tools:
            return None
        
        print(f"\n{Fore.YELLOW}[*] Running Blackbird for fast username search...{Style.RESET_ALL}\n")
        
        try:
            output_file = f"{self.osint_dir}/blackbird_results.txt"
            cmd = ['blackbird', '-u', self.username, '--dump']
            
            process = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            with open(output_file, 'w') as f:
                f.write(process.stdout)
            
            print(f"{Fore.GREEN}[✓] Blackbird completed - results saved{Style.RESET_ALL}")
            return output_file
        except subprocess.TimeoutExpired:
            print(f"{Fore.RED}[✗] Blackbird timed out{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}[✗] Blackbird error: {str(e)}{Style.RESET_ALL}")
        
        return None

    def scan_platforms(self):
        """Scan all platforms using concurrent threads"""
        print(f"\n{Fore.YELLOW}[*] Starting scan across {len(self.platforms)} platforms...{Style.RESET_ALL}\n")
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
            future_to_platform = {
                executor.submit(self.check_url, platform, data): platform 
                for platform, data in self.platforms.items()
            }
            
            for future in concurrent.futures.as_completed(future_to_platform):
                try:
                    result = future.result()
                    if result:
                        self.found_profiles.append(result)
                except Exception as e:
                    logging.error(f"Error in future: {str(e)}")

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
            chrome_options.add_argument(f'user-agent={self.session.headers["User-Agent"]}')
            
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
            
            driver.get(url)
            time.sleep(3)
            
            screenshot_path = f"{self.images_dir}/{platform_name.replace('/', '_').replace(' ', '_')}.png"
            driver.save_screenshot(screenshot_path)
            driver.quit()
            
            return screenshot_path
            
        except Exception as e:
            logging.error(f"Screenshot failed for {platform_name}: {str(e)}")
            return None

    def capture_screenshots(self):
        """Capture screenshots of all found profiles"""
        if not self.found_profiles:
            return
            
        print(f"\n{Fore.YELLOW}[*] Capturing screenshots of {len(self.found_profiles)} found profiles...{Style.RESET_ALL}\n")
        
        for profile in self.found_profiles:
            if profile.get('source') == 'whoisuser':
                print(f"{Fore.CYAN}[→] Capturing: {profile['platform']}{Style.RESET_ALL}")
                screenshot_path = self.take_screenshot(profile['url'], profile['platform'])
                if screenshot_path:
                    profile['screenshot'] = screenshot_path
                    print(f"{Fore.GREEN}[✓] Saved: {screenshot_path}{Style.RESET_ALL}")

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
        
        # Sort by platform name
        unique_profiles.sort(key=lambda x: x['platform'])
        
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
            f.write(f"Tool Version: 2.5 (Enhanced & Merged)\n")
            f.write(f"Total Platforms Scanned: {len(self.platforms)}\n")
            f.write(f"Profiles Found (Direct): {len(self.found_profiles)}\n")
            f.write(f"Profiles Found (Sherlock): {len(self.sherlock_results)}\n")
            f.write(f"Total Unique Profiles: {len(unique_profiles)}\n")
            f.write(f"Failed Checks: {len(self.failed_checks)}\n")
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
                if 'verified' in profile and profile['verified']:
                    f.write(f"   Verification: API Verified ✓\n")
                f.write("\n")
            
            if self.failed_checks:
                f.write("="*80 + "\n")
                f.write("FAILED CHECKS (For Reference)\n")
                f.write("="*80 + "\n\n")
                for i, failed in enumerate(self.failed_checks[:20], 1):  # Limit to first 20
                    f.write(f"{i}. Platform: {failed['platform']}\n")
                    f.write(f"   URL: {failed['url']}\n")
                    f.write(f"   Reason: {failed.get('reason', 'unknown')}\n")
                    if 'status' in failed:
                        f.write(f"   Status Code: {failed['status']}\n")
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
                    'tool_version': '2.5',
                    'total_platforms': len(self.platforms),
                    'profiles_found_direct': len(self.found_profiles),
                    'profiles_found_sherlock': len(self.sherlock_results),
                    'total_unique_profiles': len(unique_profiles),
                    'failed_checks': len(self.failed_checks),
                    'osint_tools_used': list(self.available_tools.keys())
                },
                'profiles': unique_profiles,
                'failed_checks': self.failed_checks[:50]  # Limit to first 50
            }, f, indent=4)
        
        # URLs List
        urls_path = f"{self.output_dir}/all_urls.txt"
        with open(urls_path, 'w', encoding='utf-8') as f:
            for profile in unique_profiles:
                f.write(f"{profile['url']}\n")
        
        print(f"\n{Fore.GREEN}[✓] Reports generated successfully{Style.RESET_ALL}")

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
        print(f"  • Failed Checks: {Fore.RED}{len(self.failed_checks)}{Style.RESET_ALL}")
        print(f"  • OSINT Tools Used: {Fore.WHITE}{len(self.available_tools)}{Style.RESET_ALL}\n")
        
        print(f"{Fore.YELLOW}Output Files:{Style.RESET_ALL}")
        print(f"  • Full Report: {Fore.WHITE}{self.output_dir}/FULL_REPORT.txt{Style.RESET_ALL}")
        print(f"  • JSON Report: {Fore.WHITE}{self.output_dir}/report.json{Style.RESET_ALL}")
        print(f"  • URLs List: {Fore.WHITE}{self.output_dir}/all_urls.txt{Style.RESET_ALL}")
        print(f"  • Screenshots: {Fore.WHITE}{self.images_dir}/{Style.RESET_ALL}")
        print(f"  • OSINT Results: {Fore.WHITE}{self.osint_dir}/{Style.RESET_ALL}\n")
        
        # Performance stats
        print(f"{Fore.YELLOW}Performance:{Style.RESET_ALL}")
        success_rate = (len(self.found_profiles) / len(self.platforms)) * 100 if self.platforms else 0
        print(f"  • Detection Rate: {Fore.CYAN}{success_rate:.1f}%{Style.RESET_ALL}")
        print(f"  • Investigation ID: {Fore.WHITE}{self.timestamp}{Style.RESET_ALL}\n")

    def run(self, capture_screenshots=True, use_osint_tools=True):
        """Execute the investigation"""
        start_time = time.time()
        
        self.print_banner()
        
        # Run external OSINT tools first
        if use_osint_tools:
            self.run_sherlock()
            self.run_maigret()
            self.run_holehe()
            self.run_blackbird()
        
        # Run our custom scanner
        self.scan_platforms()
        
        # Capture screenshots
        if capture_screenshots and self.found_profiles:
            try:
                self.capture_screenshots()
            except ImportError:
                print(f"\n{Fore.YELLOW}[!] Selenium not installed. Skipping screenshots.{Style.RESET_ALL}")
                print(f"{Fore.YELLOW}[!] Install with: pip3 install selenium webdriver-manager{Style.RESET_ALL}\n")
        
        # Generate reports
        self.generate_report()
        self.print_summary()
        
        # Cleanup
        if self.session:
            self.session.close()
        
        # Final statistics
        elapsed_time = time.time() - start_time
        print(f"{Fore.CYAN}[*] Total execution time: {elapsed_time:.2f} seconds{Style.RESET_ALL}\n")

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
        print(f"  whoisuser johndoe --no-screenshots --no-osint-tools")
        print(f"\n{Fore.CYAN}Features:{Style.RESET_ALL}")
        print(f"  • Scans 100+ platforms (social media, developer sites, gaming, etc.)")
        print(f"  • Integrates Sherlock, Maigret, Holehe, Blackbird")
        print(f"  • Automated screenshot capture")
        print(f"  • Comprehensive TXT and JSON reports")
        print(f"  • Rate limiting and smart detection")
        print(f"\n{Fore.YELLOW}For educational and authorized testing only!{Style.RESET_ALL}\n")
        sys.exit(1)
    
    username = sys.argv[1]
    capture_screenshots = '--no-screenshots' not in sys.argv
    use_osint_tools = '--no-osint-tools' not in sys.argv
    
    investigator = WhoisUser(username)
    investigator.run(capture_screenshots=capture_screenshots, use_osint_tools=use_osint_tools)

if __name__ == "__main__":
    main()
