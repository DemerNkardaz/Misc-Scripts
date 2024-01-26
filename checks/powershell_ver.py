import requests

def write_version_info_to_file(ver_name, ver_url, filename):
    try:
        with open(filename, 'w') as file:
            file.write(f'verName={ver_name}\n')
            file.write(f'verURL={ver_url}\n')
        print(f'Данные успешно записаны в файл: {filename}')
    except Exception as e:
        print(f'Ошибка при записи данных в файл: {e}')

def get_latest_powershell_installer_url():
    # URL релизов PowerShell на GitHub
    releases_url = 'https://api.github.com/repos/PowerShell/PowerShell/releases'

    try:
        # Получаем данные о релизах с GitHub API
        response = requests.get(releases_url)
        response.raise_for_status()  # Проверяем успешность запроса

        # Получаем JSON-данные о релизах
        releases = response.json()

        # Сортируем релизы по дате в убывающем порядке
        sorted_releases = sorted(releases, key=lambda x: x['published_at'], reverse=True)

        # Берем информацию о самом свежем релизе
        latest_release = sorted_releases[0]

        # Ищем MSI инсталлятор для Win x64
        installer_url = None
        for asset in latest_release['assets']:
            if asset['name'].endswith('x64.msi'):
                installer_url = asset['browser_download_url']
                break

        if installer_url:
            return latest_release['tag_name'], installer_url
        else:
            print('MSI инсталлятор не найден для Win x64.')
            return None, None

    except requests.exceptions.RequestException as e:
        print(f'Ошибка при выполнении запроса: {e}')
        return None, None

# Пример использования функции
latest_version, latest_installer_url = get_latest_powershell_installer_url()
if latest_version and latest_installer_url:
    write_version_info_to_file(latest_version, latest_installer_url, 'version_info.txt')
