# Home Lab Setup Plan – Svedberg.io
This document outlines the complete setup plan for building and automating a modern home lab with Docker, Caddy, Pi-hole, DNS automation, and service discovery via YAML.
## 📐 Architecture Overview
+ Services run in Docker (e.g. *arr stack, Jellyfin)
+ Reverse proxy and HTTPS termination via Caddy
+ Internal DNS via Pi-hole
+ External DNS via Loopia
+ Automatic config sync from `services.yaml`

## ✅ Phases and Task Breakdown
### Phase 1: Foundation & Networking
- [x] LXC container on Proxmox (Alpine) with Docker
- [x] Static IPs for Proxmox, NAS, and containers
- [x] Port forwarding from USG to Caddy (80/443)
- [x] Reserve internal IPs for all key services
- [x] Document IPs and subnet in a `network.md` file

### Phase 2: Deploy *arr Stack
- [ ] Create `docker-compose.yml` for:
+ Sonarr
+ Radarr
+ Jellyfin
+ Jellyseerr
+ Prowlarr
+ Torrent client

- [ ] Mount persistent volumes for config and media
- [ ] Confirm each service works on internal ports (e.g. `http://localhost:7878)`

### Phase 3: Deploy and Configure Caddy
- [ ] Add caddy service to Docker Compose
- [ ] Expose ports 80 and 443
- [ ] Mount a Caddyfile config file
- [ ] Configure wildcard HTTPS certs using Loopia DNS:
```json
{
  email you@svedberg.io
  acme_dns loopia
}
```
- [ ] Test local and public domains:
- [ ] `jellyfin.svedberg.io` → public
- [ ] `nas.svedberg.io` → local

### Phase 4: DNS Setup
**Internal DNS – Pi-hole**
- [ ] Deploy Pi-hole in Docker or LXC
- [ ] Add internal DNS records:
+ `*.svedberg.io` → Caddy container IP
- [ ] Set Pi-hole as DHCP-provided DNS in USG

**External DNS – Loopia**
- [ ] Enable DDNS in USG for @ record
- [ ] Add A/CNAME records in Loopia manually or via automation:
+ `jellyfin.svedberg.io`
+ `jellyseerr.svedberg.io`
- [ ] (Optional) Add wildcard * A record if supported

### Phase 5: DNS + Caddy Automation
- [ ] Create a `services.yaml` file with service definitions:
```yaml
- domain: jellyfin.svedberg.io
  target: host.docker.internal:8096
  type: external

- domain: nas.svedberg.io
  target: 192.168.1.200
  type: internal
```
- [ ] Build caddy-sync Docker container to:
+ Parse services.yaml
+ Generate Caddyfile
+ Update Loopia DNS (XML-RPC)
+ Update Pi-hole records (/etc/pihole/custom.list or API)
+ Reload Caddy (docker exec or API)
- [ ] Mount Docker socket if using docker exec
- [ ] Watch for file changes (inotify) or schedule periodic sync

### Phase 6: Monitoring and Polish
- [ ] Add logging and status checks for caddy-sync
- [ ] Monitor Pi-hole and Caddy logs
- [ ] Add optional auth to Caddy routes (e.g. HTTP basic auth)
- [ ] Create backup routine for config files
- [ ] Write test script that checks availability of each service URL
- [ ] Document credentials and secrets in .secrets.md (gitignored)

### 📁 Directory Layout (Example)
```bash
/home-lab/
│
├── docker-compose.yml
├── Caddyfile                  # Generated from YAML
├── services.yaml              # Source of truth
├── caddy-sync/                # Custom sync container
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── templates/
├── pihole/                    # Optional
├── README.md
└── .secrets.md                # Gitignored
```

### 📌 Notes
+ Internal-only services don’t need public DNS records
+ Public-facing services must have DNS + certs
+ Loopia wildcard A records are helpful but not required
+ You can combine Pi-hole and DNSMasq for advanced overrides
+ Caddy is automatically responsible for HTTPS certs (wildcard or per domain)