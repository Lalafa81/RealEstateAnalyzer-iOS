# RealEstateAnalyzer iOS

iOS приложение для анализа объектов недвижимости, портированное с Python/Web версии.

## Требования
- iOS 14.2+
- Xcode 14.2+
- Swift 5.5+

## Структура проекта

```
RealEstateAnalyzer-iOS/
├── RealEstateAnalyzer/
│   ├── App/
│   │   ├── RealEstateAnalyzerApp.swift      # Точка входа
│   ├── Models/                               # Модели данных
│   │   ├── Property.swift
│   │   ├── Tenant.swift
│   │   ├── FinancialData.swift
│   │   ├── Analytics.swift
│   ├── Services/                             # Сервисы
│   │   ├── DataManager.swift                # Работа с JSON
│   │   ├── MetricsCalculator.swift          # Расчет метрик
│   ├── Views/                                # SwiftUI Views
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── PropertyRowView.swift
│   │   ├── PropertyDetail/
│   │   │   ├── PropertyDetailView.swift
│   │   │   ├── AnalyticsView.swift
│   │   │   ├── CalendarView.swift
│   │   ├── AssetMap/
│   │   │   ├── AssetMapView.swift
│   ├── Utilities/                            # Утилиты
│   │   ├── Localization.swift
│   │   ├── Extensions.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
```

## Основные функции

1. **Dashboard** - список объектов с общей статистикой
2. **Property Detail** - детальная информация об объекте
3. **Analytics** - расчет финансовых метрик
4. **Calendar** - календарь доходов/расходов
5. **Asset Map** - визуальная карта активов

## План миграции

- [x] Создание структуры проекта
- [x] Модели данных (Property, Tenant, Analytics)
- [x] DataManager (работа с JSON)
- [x] MetricsCalculator (расчет метрик)
- [x] DashboardView (главный экран)
- [x] PropertyDetailView (детальная страница)
- [x] Базовые графики (мини-чарты)
- [ ] Полноценные графики (Swift Charts)
- [ ] Календарь доходов/расходов
- [ ] Asset Map (карта активов)
- [ ] Локализация (i18n)

## Статус

✅ **Базовая функциональность готова:**
- Модели данных полностью переведены
- DataManager работает с JSON файлами
- MetricsCalculator реализует все основные метрики
- Dashboard отображает список объектов и статистику
- PropertyDetail показывает детальную информацию и аналитику
- Базовые графики работают

🚧 **В разработке:**
- Улучшение графиков
- Календарь
- Asset Map
- Локализация

## Использование

1. Откройте проект в Xcode 14.2+
2. Выберите симулятор iOS 14.2+
3. Запустите приложение (⌘R)
4. Для загрузки данных скопируйте `data.json` в Documents директорию приложения

Подробнее см. [INSTALLATION.md](INSTALLATION.md)

