
## 🚀 Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/SpaceFlightSpace.git
   cd SpaceFlightSpace
   ```
2. Abre el proyecto en Xcode:
   ```bash
   open SpaceFlightSpace.xcodeproj
   ```
3. Ejecuta en un simulador o dispositivo iOS (iOS 17.5+).

## 🧪 Testing

- Corre los tests unitarios desde Xcode (`Cmd + U`) o por terminal:
  ```bash
  xcodebuild test -project SpaceFlightSpace.xcodeproj -scheme SpaceFlightSpace -destination 'platform=iOS Simulator,name=iPhone 15'
  ```
- Cobertura: ViewModels, DataSources, integración y performance.

## 🔌 API

- [Space Flight News API](https://api.spaceflightnewsapi.net/v4/articles/)
- Paginación, búsqueda y detalles de artículos espaciales.

## ✨ Componentes Reutilizables

- **GifImageView**: Reproducción de GIFs con control de velocidad y loop.
- **SearchBarComponent**: Barra de búsqueda custom con delegate.
- **SkeletonizableView**: Animaciones de carga para placeholders.

## 📋 Protocolos Clave

- `ArticleServiceProtocol`, `APIClientProtocol`: Networking
- `LoggerProtocol`: Logging
- `GifImageViewProtocol`, `SearchBarComponentDelegate`, `SkeletonizableView`: UI

---

**Autor:** Nico Famularo  
**GitHub:** [Nico](https://github.com/NicoFamularo)

---

