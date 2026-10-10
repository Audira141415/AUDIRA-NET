"""
Script untuk menampilkan semua user yang terdaftar di Firebase Firestore
Menggunakan Firebase REST API
"""

import requests
import json

def show_all_users():
    print('\n' + '='*60)
    print('🔥 AUDIRANET - DAFTAR USER TERDAFTAR')
    print('='*60 + '\n')
    
    # GANTI INI dengan Firebase project ID Anda
    PROJECT_ID = "datacenter-checklist-prod"  # Sesuaikan dengan project Anda
    
    # Firebase REST API endpoint
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/users"
    
    try:
        print('📡 Mengambil data dari Firebase Firestore...\n')
        
        # Kirim request ke Firebase
        response = requests.get(url)
        
        if response.status_code != 200:
            print(f'❌ Error: HTTP {response.status_code}')
            print('   Pastikan:')
            print('   1. Project ID sudah benar')
            print('   2. Firestore sudah enabled')
            print('   3. Security rules mengizinkan public read (hanya untuk testing!)')
            print('\n💡 ALTERNATIF: Buka Firebase Console')
            print('   https://console.firebase.google.com/')
            return
        
        data = response.json()
        
        if 'documents' not in data:
            print('❌ Tidak ada user ditemukan')
            print('   Collection "users" kosong atau tidak ada\n')
            return
        
        users = data['documents']
        
        # Hitung per role
        role_count = {}
        for user_doc in users:
            fields = user_doc.get('fields', {})
            role = fields.get('role', {}).get('stringValue', 'unknown')
            role_count[role] = role_count.get(role, 0) + 1
        
        # Tampilkan ringkasan
        print('📊 RINGKASAN:')
        print(f'   Total User: {len(users)}')
        for role, count in role_count.items():
            icon = '👑' if role == 'admin' else '🔧' if role == 'teknisi' else '👤' if role == 'customer' else '❓'
            print(f'   {icon} {role.upper()}: {count} user')
        print('\n' + '='*60 + '\n')
        
        # Tampilkan detail
        for idx, user_doc in enumerate(users, 1):
            fields = user_doc.get('fields', {})
            
            # Extract data
            user_id = user_doc['name'].split('/')[-1]
            name = fields.get('name', {}).get('stringValue', '-')
            email = fields.get('email', {}).get('stringValue', '-')
            role = fields.get('role', {}).get('stringValue', '-')
            phone = fields.get('phone', {}).get('stringValue', '-')
            company = fields.get('company', {}).get('stringValue', None)
            zone = fields.get('zone', {}).get('stringValue', None)
            
            # Icon
            icon = '👑' if role == 'admin' else '🔧' if role == 'teknisi' else '👤' if role == 'customer' else '❓'
            
            print(f'{icon} USER #{idx} - {role.upper()}')
            print('─' * 60)
            print(f'📝 Firebase UID : {user_id}')
            print(f'👤 Nama         : {name}')
            print(f'📧 Email        : {email}')
            print(f'📱 Telepon      : {phone}')
            
            if company:
                print(f'🏢 Perusahaan   : {company}')
            if zone:
                print(f'📍 Zona         : {zone}')
            
            print()
        
        print('='*60)
        print(f'✅ Berhasil menampilkan {len(users)} user')
        print('='*60 + '\n')
        
    except requests.exceptions.ConnectionError:
        print('❌ Error: Tidak dapat terhubung ke Firebase')
        print('   Pastikan koneksi internet aktif\n')
    except Exception as e:
        print(f'❌ Error: {str(e)}\n')
        print('💡 Solusi Mudah:')
        print('   Buka Firebase Console di browser:')
        print('   1. https://console.firebase.google.com/')
        print('   2. Pilih project Anda')
        print('   3. Menu: Authentication > Users')
        print('   atau')
        print('   3. Menu: Firestore Database > users\n')

if __name__ == '__main__':
    print('\n⚠️  CATATAN: Script ini membutuhkan Firebase REST API')
    print('   Jika error, gunakan cara lebih mudah:\n')
    print('   CARA TERMUDAH:')
    print('   1. Buka: https://console.firebase.google.com/')
    print('   2. Pilih project: datacenter-checklist-prod (atau project Anda)')
    print('   3. Klik: Authentication > Users')
    print('   4. Lihat semua user yang terdaftar\n')
    print('─' * 60 + '\n')
    
    choice = input('Lanjut coba REST API? (y/n): ').lower()
    
    if choice == 'y':
        show_all_users()
    else:
        print('\n✅ Silakan buka Firebase Console untuk melihat user')
        print('   https://console.firebase.google.com/\n')
