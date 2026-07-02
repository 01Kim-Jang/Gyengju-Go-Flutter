import os
import json
import urllib.request
import re

# Odii API details
API_KEY = "0eccca5dbe3449337090f9338bd258f0d50126e3dc873fc785ecf7b09c01ced0"
ODII_URL = f"https://apis.data.go.kr/B551011/Odii/themeBasedList?serviceKey={API_KEY}&numOfRows=5000&pageNo=1&MobileOS=AND&MobileApp=GyeongjuGo&_type=json&langCode=ko"

OUTPUT_DIR = "assets/images/spots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def fetch_wikipedia_image(title):
    # Clean title
    clean_title = re.sub(r'\([^)]*\)', '', title).replace('경주', '').strip()
    clean_title = clean_title.replace(' ', '')
    
    # Wiki API
    wiki_url = f"https://ko.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(clean_title)}&prop=pageimages&format=json&pithumbsize=800"
    try:
        req = urllib.request.Request(wiki_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                if 'thumbnail' in page_data:
                    return page_data['thumbnail']['source']
    except Exception as e:
        print(f"Wiki error for {title}: {e}")
    
    # Try with original title if clean fails
    wiki_url2 = f"https://ko.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=pageimages&format=json&pithumbsize=800"
    try:
        req = urllib.request.Request(wiki_url2, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                if 'thumbnail' in page_data:
                    return page_data['thumbnail']['source']
    except:
        pass
    
    return None

print("Fetching spots from Odii API...")
try:
    req = urllib.request.Request(ODII_URL)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        items = data['response']['body']['items']['item']
        
        gyeongju_spots = []
        for i in items:
            addr1 = str(i.get('addr1', '')).lower()
            addr2 = str(i.get('addr2', '')).lower()
            title = str(i.get('title', '')).lower()
            if '경주' in addr1 or '경주' in addr2 or '경주' in title:
                gyeongju_spots.append(i)
                
        print(f"Found {len(gyeongju_spots)} Gyeongju spots.")
        
        for spot in gyeongju_spots:
            title = spot['title']
            file_name = f"{title.replace(' ', '_').replace('/', '_')}.jpg"
            file_path = os.path.join(OUTPUT_DIR, file_name)
            
            if os.path.exists(file_path):
                print(f"Already downloaded: {title}")
                continue
                
            image_url = spot.get('imageUrl', '')
            
            if not image_url:
                print(f"Searching Wikipedia for: {title}")
                image_url = fetch_wikipedia_image(title)
                
            if image_url:
                try:
                    #print(f"Downloading {image_url} for {title}...")
                    req_img = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req_img) as img_res:
                        with open(file_path, 'wb') as f:
                            f.write(img_res.read())
                except Exception as e:
                    print(f"Failed to download image for {title}: {e}")
            else:
                print(f"No image found for {title}, using default.")
                # We can fallback to default URL
                default_url = 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg'
                try:
                    req_img = urllib.request.Request(default_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req_img) as img_res:
                        with open(file_path, 'wb') as f:
                            f.write(img_res.read())
                except:
                    pass
                
except Exception as e:
    print(f"Error: {e}")

print("Done!")
