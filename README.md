# 💰 Localito — Control de Gastos Personales

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local%20DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Android](https://img.shields.io/badge/Android-APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Estado](https://img.shields.io/badge/Estado-Completado-brightgreen?style=for-the-badge)
![UPI](https://img.shields.io/badge/Universidad-UPI%20Panamá-red?style=for-the-badge)

> **Proyecto Final** · Programación Móvil · Universidad Politécnica Internacional

---

## 📋 Descripción

**Localito** es una aplicación móvil Android desarrollada con **Flutter y Dart** que permite al usuario registrar y controlar sus ingresos y gastos personales. Clasifica cada movimiento por categoría, muestra el saldo disponible en tiempo real y mantiene un historial completo de transacciones. Toda la información se almacena localmente mediante **SQLite**, sin necesidad de internet, backend ni servidores externos.

---

## ⚙️ Funcionalidades

| # | Función | Descripción |
|---|---------|-------------|
| 1 | 💵 Registrar ingresos | Agrega ingresos con monto, categoría, descripción y fecha |
| 2 | 💸 Registrar gastos | Agrega gastos con todos sus datos detallados |
| 3 | 🏷️ Categorías | 8 categorías de gasto + 5 de ingreso + categorías personalizadas |
| 4 | 📋 Listado de transacciones | Vista completa con filtros por tipo (Todas / Ingresos / Gastos) |
| 5 | 📊 Total de ingresos | Suma de todos los ingresos registrados |
| 6 | 📊 Total de gastos | Suma de todos los gastos registrados |
| 7 | 💼 Saldo disponible | Cálculo automático: Ingresos − Gastos |
| 8 | ✏️ Editar registros | Modifica cualquier transacción existente |
| 9 | 🗑️ Eliminar registros | Elimina transacciones con confirmación |
| 10 | 🗄️ Base de datos SQLite | Almacenamiento 100% local en el dispositivo |
| 11 | 🎨 Interfaz amigable | UI moderna con Material 3 y colores intuitivos |

---

## 🏷️ Categorías disponibles

**Gastos:**
```
🍽️ Alimentación   🚗 Transporte   🏥 Salud        🎓 Educación
🧾 Servicios      🎬 Entretenimiento  🛍️ Compras  ➕ Otros
```

**Ingresos:**
```
💼 Salario   💻 Freelance   📈 Inversiones   🎁 Regalo   ➕ Otros
```

> También puedes crear tus propias categorías con ícono personalizado desde la app.

---

## 🗄️ Estructura de la base de datos SQLite

```sql
-- Tabla principal de transacciones
CREATE TABLE transactions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  type        TEXT NOT NULL,   -- 'ingreso' o 'gasto'
  amount      REAL NOT NULL,   -- Monto (ej: 1250.50)
  category    TEXT NOT NULL,   -- Categoría seleccionada
  description TEXT NOT NULL,   -- Descripción del movimiento
  date        TEXT NOT NULL    -- Fecha en formato ISO 8601
);

-- Tabla de categorías personalizadas
CREATE TABLE categories (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  name     TEXT NOT NULL,      -- Nombre de la categoría
  type     TEXT NOT NULL,      -- 'ingreso' o 'gasto'
  icon_key TEXT NOT NULL DEFAULT 'label'  -- Clave del ícono seleccionado
);
```

---

## 🧠 Conceptos aplicados

```
✔ Modelos de datos con clases Dart (fromMap / toMap)
✔ Base de datos SQLite con sqflite (CRUD completo)
✔ Patrón Singleton para la conexión a la BD
✔ Gestión de estado con StatefulWidget y setState
✔ Navegación entre pantallas con Navigator y MaterialPageRoute
✔ Widgets personalizados: TransactionCard, CategoryTile
✔ SliverAppBar y CustomScrollView para UI animada
✔ Manejo asíncrono con async / await y Future
✔ Operadores aritméticos para cálculo de saldo
✔ Estructuras if / else para validaciones
✔ Formateo de montos con separadores de miles (1,250.00)
✔ Migraciones de base de datos con onUpgrade
```

---

## 📱 Instalación

### Opción A — Descargar el APK directo
1. Ve a la sección [**Releases**](https://github.com/hugoparnther-stack/localito_directorio_local/releases)
2. Descarga el archivo `app-release.apk`
3. En tu Android: **Ajustes → Seguridad → Instalar apps desconocidas**
4. Abre el APK e instala

### Opción B — Compilar desde el código fuente

**1.** Clona el repositorio:
```bash
git clone https://github.com/hugoparnther-stack/localito_directorio_local.git
```

**2.** Entra a la carpeta:
```bash
cd localito_directorio_local
```

**3.** Instala dependencias:
```bash
flutter pub get
```

**4.** Ejecuta en un dispositivo conectado:
```bash
flutter run
```

**5.** O genera el APK:
```bash
flutter build apk --release
```

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Versión | Uso |
|-----------|---------|-----|
| Flutter | 3.x | Framework de UI multiplataforma |
| Dart | 3.x | Lenguaje de programación |
| sqflite | ^2.3.0 | Base de datos SQLite local |
| path | ^1.8.3 | Manejo de rutas del sistema |
| intl | ^0.19.0 | Internacionalización y fechas |

---

## 👤 Autor

**Hugo Parnther**  
Estudiante de Programación Móvil · Universidad Politécnica Internacional

---

<p align="center">Hecho con 💙 Flutter · Panamá 🇵🇦</p>
