# Con Parque de Bolas — CLAUDE.md

## WHAT — Qué es y cómo está organizado

Web estática que lista restaurantes kids-friendly en la provincia de Cádiz (con arquitectura preparada para escalar a otras provincias).

**Repo:** `github.com/3oheme/conparquedebolas`  
**Producción:** `https://conparquedebolas.com` (DNS en Cloudflare → Netlify, SSL via Let's Encrypt)  
**Stack:** Jekyll 4.3 + Ruby 3.3 + YAML + JS vanilla

### Estructura del proyecto

```
conparquedebolas/          ← raíz del repo git
  netlify.toml             ← config de build para Netlify
  conparquedebolas/        ← sitio Jekyll
    _data/
      cadiz.yml            ← lista plana de restaurantes de Cádiz
    _layouts/
      restaurante.html     ← vista detalle de un restaurante
      ciudad.html          ← vista listado de una ciudad
    _plugins/
      restaurantes_generator.rb  ← genera /restaurantes/[slug]/ y /ciudades/[slug]/ a partir del YAML
    _sass/
      parquedebolas.scss   ← todos los estilos del proyecto
    assets/
      main.scss            ← punto de entrada SCSS (importa minima + parquedebolas)
      img/restaurantes/    ← imágenes de portada (ratio 16:9, JPG o WebP)
    index.html             ← listado principal agrupado por ciudad
    _config.yml
    Gemfile
```

### Páginas generadas

| URL | Origen |
|---|---|
| `/` | `index.html` — listado de todas las ciudades y sus restaurantes |
| `/ciudades/[slug]/` | Generada por el plugin a partir del YAML |
| `/restaurantes/[slug]/` | Generada por el plugin a partir del YAML |

### Estructura de un restaurante en el YAML

```yaml
- nombre: "Nombre del restaurante"
  slug: "nombre-del-restaurante"       # usado como URL
  ciudad: "Jerez de la Frontera"       # debe coincidir exactamente entre restaurantes de la misma ciudad
  por_que_kids_friendly: >             # campo estrella, máx. 300 caracteres
    Descripción de por qué es especial para familias.
  descripcion_general: "Cocina tipo. Precio medio."   # opcional
  direccion: "Calle Ejemplo, 1, 11401 Ciudad"
  valoracion_kids: 4.5                 # 1–5, un decimal
  imagen: "/assets/img/restaurantes/slug.jpg"          # opcional
  web: "https://www.ejemplo.com"                      # opcional
  instagram: "handle_sin_arroba"                      # opcional, solo el handle
  lat: 36.5268                                        # necesario para mostrar el mapa en la ficha
  lng: -6.2989                                        # necesario para mostrar el mapa en la ficha
  ultima_verificacion: "2025-04-30"
  tags:
    tronas: true
    carta_infantil: true
    zona_juegos: false
    cambiador: true
    terraza: true
    mascotas: false
    accesible: true
    opciones_saludables: false
  precio: "€€"                         # €, €€ o €€€ — opcional
```

### Tags disponibles

| Campo YAML | Icono | Descripción |
|---|:---:|---|
| `tronas` | 🪑 | Tronas para bebés |
| `carta_infantil` | 🧒 | Menú específico para niños |
| `zona_juegos` | 🎮 | Área de juegos interior o exterior |
| `cambiador` | 🚻 | Cambiador en baños |
| `terraza` | 🌿 | Terraza exterior |
| `mascotas` | 🐶 | Admite mascotas |
| `accesible` | ♿ | Accesible para carritos y sillas de ruedas |
| `opciones_saludables` | 🥗 | Opciones saludables en carta |

---

## WHY — Propósito

Ayudar a familias con niños a encontrar restaurantes donde comer sin estrés. El criterio principal no es la calidad gastronómica sino la experiencia para las familias: tronas, espacio, paciencia del personal, zonas de juego.

Fase inicial: provincia de Cádiz. La arquitectura (un YAML por provincia, un plugin que genera páginas) está diseñada para escalar a otras provincias añadiendo un nuevo fichero YAML y registrando la provincia en el plugin.

---

## HOW — Cómo trabajar en el proyecto

### Arrancar el servidor local

```bash
cd conparquedebolas/conparquedebolas
/usr/local/opt/ruby@3.3/bin/bundle exec jekyll serve
```

El site queda disponible en `http://localhost:4000/`.

> Ruby del sistema (2.6) es demasiado antiguo. Usar siempre el de Homebrew: `/usr/local/opt/ruby@3.3/bin/`.

### Añadir un restaurante

1. Abrir `conparquedebolas/_data/cadiz.yml`
2. Añadir una entrada siguiendo la estructura YAML de arriba
3. El `slug` debe ser único y en minúsculas sin tildes (ej. `el-faro-de-cadiz`)
4. Si la ciudad es nueva, escribirla exactamente igual que aparecerá en los títulos
5. Obtener `lat` y `lng` desde Google Maps (click derecho sobre el punto → copiar coordenadas) — sin ellos el mapa no se muestra en la ficha
6. `web` e `instagram` son opcionales e independientes; un restaurante puede tener ambos, uno o ninguno. En `instagram` se escribe solo el handle, sin `https://instagram.com/`
7. El servidor regenera las páginas automáticamente al guardar

### Añadir una nueva provincia

1. Crear `conparquedebolas/_data/[provincia].yml` con la lista de restaurantes
2. En `_plugins/restaurantes_generator.rb`, añadir la nueva fuente de datos al método `generate`

### Hacer deploy

El deploy es automático: cada `git push` a `main` dispara un build en Netlify.

```bash
git add .
git commit -m "descripción del cambio"
git push
```

---

## Roadmap

| Funcionalidad | Fase |
|---|:---:|
| Listado por ciudad con tarjetas | MVP ✅ |
| Vista detalle por restaurante | MVP ✅ |
| Subpágina por ciudad | MVP ✅ |
| Filtro por tags | v2 |
| Buscador por nombre | v2 |
| Alta de restaurantes vía GitHub Issues | v2 |
| Extensión a otras provincias | v2 |
| Valoraciones de usuarios | v3 |
