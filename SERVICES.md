# Dark NAS Services Overview

This document provides an overview of all services running in the Docker Compose stack, their purposes, access URLs, configuration paths, and mounted volumes.

## Service Architecture

The stack consists of media management, indexing, and streaming services connected through Docker networks:
- **mediarr**: Main network for media automation services
- **transmission**: External network for torrent client connectivity
- **firefox**: Bridge network for Firefox container

## Services Overview

### 🎬 Media Streaming

#### Jellyfin
- **Purpose**: Media server for streaming movies, TV shows, and anime
- **Access**: `http://127.0.0.1:8080` (default Jellyfin port)
- **Image**: `jellyfin/jellyfin`
- **Configuration**: `/docker/jellyfin/etc` → `/etc/jellyfin`
- **Data Directories**:
  - Cache: `/docker/jellyfin/var-cache` → `/var/cache/jellyfin`
  - Library: `/docker/jellyfin/var-lib` → `/var/lib/jellyfin`
  - Logs: `/docker/jellyfin/var-log` → `/var/log/jellyfin`
- **Media Access**: `media` volume → `/mnt/media`
- **Hardware Acceleration**: Intel GPU (`/dev/dri/renderD128`)

### 📺 Media Management

#### Sonarr (TV Shows)
- **Purpose**: Automated TV show downloading and management
- **Access**: `http://127.0.0.1:8989`
- **Image**: `lscr.io/linuxserver/sonarr:latest`
- **Configuration**: `/docker/sonarr` → `/config`
- **Media Access**: 
  - Library: `media` volume → `/mnt/media`
  - Downloads: `completed` volume → `/mnt/downloads`
- **Networks**: `mediarr`, `transmission`
- **Dependencies**: Prowlarr, Jackett, Jellyfin

#### Radarr (Movies)
- **Purpose**: Automated movie downloading and management
- **Access**: `http://127.0.0.1:7878`
- **Image**: `lscr.io/linuxserver/radarr:latest`
- **Configuration**: `/docker/radarr` → `/config`
- **Media Access**:
  - Library: `media` volume → `/mnt/media`
  - Downloads: `completed` volume → `/mnt/downloads`
- **Networks**: `mediarr`, `transmission`
- **Dependencies**: Prowlarr, Jackett, Jellyfin

#### Bazarr (Subtitles)
- **Purpose**: Automated subtitle downloading for movies and TV shows
- **Access**: `http://127.0.0.1:6767`
- **Image**: `lscr.io/linuxserver/bazarr:latest`
- **Configuration**: `/docker/bazarr` → `/config`
- **Media Access**: `media` volume → `/mnt/media`
- **Networks**: `mediarr`
- **Dependencies**: Sonarr, Radarr

### 🔍 Indexers & Search

#### Prowlarr
- **Purpose**: Indexer manager for torrent and usenet sites
- **Access**: `http://127.0.0.1:9696`
- **Image**: `linuxserver/prowlarr:latest`
- **Configuration**: `/docker/prowlarr` → `/config`
- **Networks**: `mediarr`
- **Dependencies**: Flaresolverr

#### Jackett
- **Purpose**: Additional torrent indexer proxy
- **Access**: `http://127.0.0.1:9117`
- **Image**: `lscr.io/linuxserver/jackett:latest`
- **Configuration**: `/docker/jackett` → `/config`
- **Downloads**: `completed` volume → `/downloads`
- **Networks**: `mediarr`
- **Dependencies**: Flaresolverr
- **Environment**:
  - Auto-update enabled
  - Timezone: UTC

#### Flaresolverr
- **Purpose**: Cloudflare bypass proxy for indexers
- **Access**: Internal service (no web UI)
- **Image**: `ghcr.io/flaresolverr/flaresolverr:latest`
- **Networks**: `mediarr`
- **Environment Variables**:
  - `LOG_LEVEL`: Configurable (default: info)
  - `LOG_HTML`: Configurable (default: false)
  - `CAPTCHA_SOLVER`: Configurable (default: none)

### 🎯 Request Management

#### Jellyseerr
- **Purpose**: Media request management for users
- **Access**: `http://127.0.0.1:5055`
- **Image**: `fallenbagel/jellyseerr:latest`
- **Configuration**: `/docker/jellyseerr` → `/app/config`
- **Networks**: `mediarr`
- **Dependencies**: Sonarr, Radarr

### 🎌 Anime Management

#### Shoko Server
- **Purpose**: Anime collection management and metadata
- **Access**: `http://127.0.0.1:8111`
- **Image**: `ghcr.io/shokoanime/server:latest`
- **Configuration**: `/docker/shoko` → `/home/shoko/.shoko`
- **Media Access**:
  - Anime Library: `animes` volume → `/mnt/anime`
  - Import Directory: `media` volume → `/mnt/import`
- **Networks**: `mediarr`
- **Memory**: 256MB shared memory

#### Plex
- **Note**: Plex is not running on Docker. It is installed directly on the host.
- **Purpose**: Media server for anime streaming
- **Access**: `http://127.0.0.1:32400`
- **Configuration**: `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/`

## Volume Mappings

### Named Volumes
- **media**: `${MEDIA_DRIVE}` → Main media storage
- **completed**: `${MEDIA_DRIVE}/completed` → Download completion directory
- **animes**: `${MEDIA_DRIVE}/Animes` → Anime-specific storage
- **movies**: `${MEDIA_DRIVE}/Movies` → Movie-specific storage

### Configuration Directories
All service configurations are stored under `/docker/[service-name]` on the host:

```
/docker/
├── bazarr/          # Bazarr configuration
├── jellyfin/        # Jellyfin configuration and data
│   ├── etc/         # Jellyfin config files
│   ├── var-cache/   # Jellyfin cache
│   ├── var-lib/     # Jellyfin library database
│   └── var-log/     # Jellyfin logs
├── jellyseerr/      # Jellyseerr configuration
├── jackett/         # Jackett configuration
├── prowlarr/        # Prowlarr configuration
├── radarr/          # Radarr configuration
├── shoko/           # Shoko Server configuration
└── sonarr/          # Sonarr configuration
```

## Network Architecture

- **mediarr**: Primary network for media services communication
- **transmission**: External network for torrent client integration
- **firefox**: Isolated network for browser container

## Service Dependencies

```
Jellyfin (Media Server)
├── Sonarr (TV) → Prowlarr, Jackett
├── Radarr (Movies) → Prowlarr, Jackett
└── Bazarr (Subtitles) → Sonarr, Radarr

Indexers
├── Prowlarr → Flaresolverr
└── Jackett → Flaresolverr

Request Management
└── Jellyseerr → Sonarr, Radarr

Anime Management
└── Shoko Server (Standalone)
```

## Environment Variables

The stack uses the following environment variable:
- **MEDIA_DRIVE**: Base path for media storage (used in volume definitions)

Additional environment variables for Flaresolverr:
- **LOG_LEVEL**: Logging verbosity (default: info)
- **LOG_HTML**: HTML logging (default: false)
- **CAPTCHA_SOLVER**: Captcha solving method (default: none)

## Backup Considerations

### Critical Configuration Directories
- `/docker/` - All service configurations
- Database files within each service's config directory

### Media Content
- `${MEDIA_DRIVE}` - All media files and downloads
- Consider the size and backup strategy for large media collections

## Maintenance Notes

- All services use `restart: unless-stopped` for automatic recovery
- Jackett has auto-update enabled
- Hardware acceleration is configured for Jellyfin (Intel GPU)
- Services are configured to run without explicit user mapping (using container defaults)
