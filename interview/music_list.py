#!/usr/bin/env python3
#
#--- Apple ---
# Write a program (In your preferred programming language) to generate a Sorted List of 
# Artists from “Billboard Hot 100” based on the total number of letters in their track title.
# You can find Billboard Hot 100 list at : https://www.billboard.com/charts/hot-100
#
# ---------------------------------------------------------------------------
# Script: music_list.py
# Description: Fetches the Billboard Hot 100 chart and generates a sorted list
#              of artists based on the total number of letters in their track titles.
#
# Requirements:
#   - Python 3.x
#   - Libraries: requests, beautifulsoup4
#
# Usage:
#   Run the script directly:
#       python3 music_list.py
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date: April 12, 2025
# ---------------------------------------------------------------------------

import requests
from bs4 import BeautifulSoup
import re

# URL of the Billboard Hot 100 chart
url = "https://www.billboard.com/charts/hot-100/"

print("Fetching Billboard Hot 100 chart...")
response = requests.get(url)
if response.status_code != 200:
    print("Failed to fetch Billboard Hot 100 data.")
    exit(1)

# Parse HTML content
soup = BeautifulSoup(response.text, "html.parser")

# Track titles are in <h3 id="title-of-a-story"...>
track_tags = soup.find_all("h3", id="title-of-a-story")
track_titles = [tag.get_text(strip=True) for tag in track_tags if tag.get_text(strip=True)]

# Artist names are in <span class="c-label  a-no-trucate ...">
artist_tags = soup.select('span.c-label.a-no-trucate')
artist_names = [tag.get_text(strip=True) for tag in artist_tags if tag.get_text(strip=True)]

# Ensure we only work with pairs where both artist and title exist
min_len = min(len(track_titles), len(artist_names))
tracks = list(zip(track_titles[:min_len], artist_names[:min_len]))

# Function to count only alphabetic characters in the title
def count_letters(s):
    return len(re.sub(r'[^A-Za-z]', '', s))

# Sort by number of letters in track title
sorted_tracks = sorted(tracks, key=lambda x: count_letters(x[0]), reverse=True)

# Output the sorted result
print("\n Billboard Hot 100 - Sorted by Track Title Letter Count:\n")
for i, (title, artist) in enumerate(sorted_tracks, 1):
    print(f"{i:2}. {artist:25} - {title} ({count_letters(title)} letters)")
