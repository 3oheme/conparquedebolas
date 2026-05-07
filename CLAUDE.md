# Con Parque de Bolas — CLAUDE.md

## WHAT — Qué es y cómo está organizado

Web estática que lista restaurantes kids-friendly en la provincia de Cádiz (con arquitectura preparada para escalar a otras provincias).

**Repo:** `github.com/3oheme/conparquedebolas`  
**Producción:** `https://conparquedebolas.com` (DNS en Cloudflare → Netlify, SSL via Let's Encrypt)  
**Email:** `hola@conparquedebolas.com` (Cloudflare Email Routing → Gmail)  
**Stack:** Jekyll 4.3 + Ruby 3.3 + YAML + JS vanilla

### Estructura del proyecto

```
conparquedebolas/          ← raíz del repo git
  netlify.toml             ← config de build para Netlify
  conparquedebolas/        ← sitio Jekyll
    _data/
      cadiz.yml            ← lista plana de restaurantes de Cádiz
      i18n.yml             ← strings de UI en ES y EN
    _layouts/
      home.html            ← listado principal (ES y EN)
      restaurante.html     ← vista detalle de un restaurante
      ciudad.html          ← vista listado de una ciudad
      filtro.html          ← vista listado filtrada por tag
      contacto.html        ← formulario de contacto (Netlify Forms)
      gracias.html         ← página de confirmación post-envío
    _includes/
      header.html          ← cabecera con selector de idioma
      footer.html          ← pie con enlace de contacto y email
      head.html            ← meta tags + hreflang
    _plugins/
      restaurantes_generator.rb  ← genera todas las páginas dinámicas a partir del YAML
    _sass/
      parquedebolas.scss   ← todos los estilos del proyecto
    assets/
      main.scss            ← punto de entrada SCSS (importa minima + parquedebolas)
      img/restaurantes/    ← imágenes de portada (ratio 16:9, JPG o WebP)
    index.html             ← home ES
    contacto.html          ← página de contacto ES
    gracias.html           ← página de gracias ES
    en/
      contacto.html        ← página de contacto EN
      gracias.html         ← página de gracias EN
    _config.yml
    Gemfile
```

### Páginas generadas por el plugin

| URL | Descripción |
|---|---|
| `/` | Home ES — listado agrupado por ciudad |
| `/en/` | Home EN |
| `/restaurantes/[slug]/` | Ficha detalle ES |
| `/en/restaurantes/[slug]/` | Ficha detalle EN (solo si tiene `por_que_kids_friendly_en`) |
| `/ciudades/[slug]/` | Listado de una ciudad ES |
| `/en/ciudades/[slug]/` | Listado de una ciudad EN |
| `/con/[tag]/` | Filtro por tag, toda la provincia ES |
| `/en/con/[tag]/` | Filtro por tag EN |
| `/ciudades/[slug]/con/[tag]/` | Filtro por tag dentro de una ciudad ES |
| `/en/ciudades/[slug]/con/[tag]/` | Filtro por tag dentro de una ciudad EN |

### Estructura de un restaurante en el YAML

```yaml
- nombre: "Nombre del restaurante"
  slug: "nombre-del-restaurante"           # usado como URL
  ciudad: "Jerez de la Frontera"           # debe coincidir exactamente entre restaurantes de la misma ciudad
  por_que_kids_friendly: >                 # campo estrella ES, máx. 300 caracteres
    Descripción de por qué es especial para familias.
  por_que_kids_friendly_en: >             # ídem en EN — si está vacío, no se genera página EN
    Description of why it's special for families.
  descripcion_general: "Cocina tipo. Precio medio."
  descripcion_general_en: "Cuisine type. Average price."
  direccion: "Calle Ejemplo, 1, 11401 Ciudad"
  valoracion_kids: 4.5                     # 1–5, un decimal — determina el orden en los listados
  imagen: "/assets/img/restaurantes/slug.jpg"   # opcional
  web: "https://www.ejemplo.com"               # opcional
  instagram: "handle_sin_arroba"               # opcional, solo el handle
  lat: 36.5268                                 # necesario para mostrar el mapa en la ficha
  lng: -6.2989
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
  precio: "€€"                             # €, €€ o €€€ — opcional
```

> Los restaurantes se ordenan por `valoracion_kids` descendente en todos los listados.  
> No existe el campo `horario` — se eliminó intencionalmente para evitar desactualizaciones.

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
> Si el servidor ya está corriendo y hay cambios que no se reflejan, ejecutar `jekyll build` para forzar regeneración.

### Añadir un restaurante

1. Abrir `conparquedebolas/_data/cadiz.yml`
2. Añadir una entrada siguiendo la estructura YAML de arriba
3. El `slug` debe ser único y en minúsculas sin tildes (ej. `el-faro-de-cadiz`)
4. Si la ciudad es nueva, escribirla exactamente igual que aparecerá en los títulos
5. Obtener `lat` y `lng` desde Google Maps (click derecho sobre el punto → copiar coordenadas) — sin ellos el mapa no se muestra en la ficha
6. `web` e `instagram` son opcionales. En `instagram` se escribe solo el handle, sin `https://instagram.com/`
7. Añadir imagen en `assets/img/restaurantes/[slug].jpg` (ratio 16:9 recomendado)
8. Si no se rellena `por_que_kids_friendly_en`, el restaurante no tendrá página EN

### Añadir una nueva provincia

1. Crear `conparquedebolas/_data/[provincia].yml` con la lista de restaurantes
2. En `_plugins/restaurantes_generator.rb`, añadir la nueva fuente de datos al método `generate`

### Flujo de trabajo: ramas

El repositorio tiene dos ramas:

- **`dev`** — desarrollo diario. Commits libres, sin coste de build.
- **`main`** — producción. Cada push dispara un build en Netlify.

Flujo normal:

```bash
# Trabajar en dev
git checkout dev
git add archivo
git commit -m "descripción del cambio"

# Cuando el bloque de trabajo está listo para producción
git checkout main
git merge dev
git push          # ← único deploy
git checkout dev  # volver a dev para seguir trabajando
```

> Netlify está configurado para ignorar builds de cualquier rama que no sea `main` (`ignore` en `netlify.toml`).  
> GitHub Pages está desactivado — el site vive únicamente en Netlify.  
> Si el push falla por tamaño (imágenes), ejecutar primero: `git config http.postBuffer 524288000`

---

## Roadmap

| Funcionalidad | Fase |
|---|:---:|
| Listado por ciudad con tarjetas clicables | MVP ✅ |
| Vista detalle por restaurante | MVP ✅ |
| Subpágina por ciudad | MVP ✅ |
| Filtro por tags (`/con/[tag]/` y `/ciudades/[slug]/con/[tag]/`) | MVP ✅ |
| Imágenes en tarjetas y ficha detalle | MVP ✅ |
| i18n ES/EN completo | MVP ✅ |
| Formulario de contacto (Netlify Forms, ES + EN) | MVP ✅ |
| Email `hola@conparquedebolas.com` (Cloudflare routing) | MVP ✅ |
| Ordenación por `valoracion_kids` | MVP ✅ |
| Buscador por nombre | v2 |
| Alta de restaurantes vía GitHub Issues | v2 |
| Más ciudades de Cádiz (Cádiz capital, Conil, Vejer, Tarifa, Sanlúcar) | v2 |
| Extensión a otras provincias | v3 |
| Valoraciones de usuarios | v3 |
