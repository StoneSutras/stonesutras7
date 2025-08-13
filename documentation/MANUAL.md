# Project Documentation: Buddhist Stone Sutras in China

## 1. Introduction

This document provides a comprehensive overview of the "Buddhist Stone Sutras in China" project. It details the technical implementation, customizations, and development workflows. The project is a digital edition of Buddhist sutras carved in stone in China, presented as a web application.

### 1.1. Project Overview

The "Buddhist Stone Sutras in China" is a digital humanities project that provides access to a collection of Buddhist sutras inscribed on stone. The web application allows users to explore the sutras, view high-resolution images, and search the text. It also provides rich metadata about the inscriptions, including their geographical location, historical context, and scholarly commentary.

### 1.2. Technical Stack

The application is built on the following technologies:

- **eXist-db**: A native XML database that stores the TEI-encoded documents and other data.
- **TEI Publisher**: An application for publishing TEI documents, which provides the core framework for the project.
- **Polymer Web Components**: The user interface is built with a set of web components, primarily from the `@teipublisher/pb-components` library.
- **XQuery**: The language used for server-side logic and APIs within eXist-db.
- **HTML/CSS/JavaScript**: Standard web technologies for the frontend presentation and interactivity.
- **npm**: Used for managing frontend dependencies.
- **Ant**: Used for the build process.

## 2. Project Setup and Build Process

This section describes how the project is configured and built.

### 2.1. eXist-db Package (`expath-pkg.xml`)

The `expath-pkg.xml` file defines the application as a package for the eXist-db. It contains the following key information:

- **Package Name**: `https://stonesutras.org/apps/web`
- **Abbreviation**: `stonesutras7`
- **Title**: `中國佛教石經 | Buddhist Stone Sutras in China`
- **Dependencies**: The project depends on the following packages:
  - `http://existsolutions.com/apps/tei-publisher-lib`: The core TEI Publisher library.
  - `http://e-editiones.org/roaster`: A library for RESTful API routing.
  - `http://exist-db.org/html-templating`: The HTML templating library for eXist-db.

### 2.2. Frontend Dependencies (`package.json`)

The project uses `npm` to manage its frontend dependencies. The `package.json` file specifies the following dependency:

- **`@teipublisher/pb-components`**: This package provides the Polymer-based web components that are the building blocks of the user interface.

To install the frontend dependencies, run the following command in the root of the project:

```bash
npm install
```

### 2.3. Build Process (`build.xml`)

The project uses Apache Ant for its build process, which is defined in the `build.xml` file. The build process performs the following main tasks:

1.  **`npm.install`**: Runs `npm install` to download the frontend dependencies into the `node_modules` directory.
2.  **`prepare`**: Copies the necessary frontend assets (JavaScript, CSS, images, fonts) from `node_modules` into the `resources` directory of the application. This makes them available to the web application at runtime.
3.  **`xar`**: Creates a `.xar` (eXist Application Archive) file in the `build` directory. This file is the deployable package for the eXist-db.

To build the application, run the following command:

```bash
ant xar-local
```

This will execute the `npm.install`, `prepare`, and `xar` targets in sequence.

## 3. Frontend Customizations

The frontend of the application has been extensively customized to meet the project's specific requirements. This section details these customizations.

### 3.1. HTML Templates

The HTML templates are located in the `templates` directory. The main entry point for the application is `templates/index.html`. This file sets up the main page layout, including the header, footer, and navigation.

Other important templates include:
- `templates/pages/stonesutras.html`: A custom page for the project.
- `templates/pages/view.html`: A generic view page.
- `templates/article.html`, `templates/person.html`, etc.: Templates for displaying specific data types.

The templates use a combination of standard HTML and custom web components to create the user interface.

### 3.2. Web Components

The application's UI is built using Polymer web components from the `@teipublisher/pb-components` library. These components are used for a wide range of functionalities, such as:

- **`pb-page`**: The main component that encapsulates a page.
- **`pb-load`**: For loading data from an API endpoint.
- **`pb-leaflet-map`**: For displaying interactive maps.
- **`pb-search`**: A search component.
- **`pb-i18n`**: For internationalization.
- **`pb-login`**: For user authentication.

These components are configured and composed in the HTML templates to build the application's views.

### 3.3. Custom CSS (`stonesutras-theme.css`)

The visual appearance of the application is customized through a dedicated stylesheet located at `resources/css/stonesutras-theme.css`. This file contains styles for:

- **Colors and Fonts**: Custom color schemes and typography.
- **Layout**: Custom grid layouts for different pages and views.
- **Component Styling**: Overrides and extensions of the default styles of the `pb-components`.
- **Responsive Design**: Media queries to adapt the layout for different screen sizes.

### 3.4. Custom JavaScript (`app.js`)

Custom client-side logic is implemented in `resources/scripts/app.js`. This script is responsible for:

- **Event Handling**: It sets up event listeners to handle user interactions, such as clicks on map markers or facet checkboxes.
- **Component Communication**: It facilitates communication between different web components using the `pbEvents` publish/subscribe system.
- **Dynamic Content**: It dynamically loads and updates content, such as the side-by-side text view and the image lightbox.
- **Map Integration**: It integrates the `pb-leaflet-map` component with the application's data and user interface.

## 4. Backend Customizations

The backend of the application is where the data is stored, managed, and exposed to the frontend. This section covers the backend customizations.

### 4.1. Custom APIs (`custom-api.xql`)

The core of the backend customizations is the `modules/custom-api.xql` XQuery module. This file defines a set of custom functions that serve as API endpoints for the frontend. The frontend components (like `pb-load`) call these endpoints to fetch data.

Key API functions include:

- **`api:sites`**: Returns a list of sites with their geographical coordinates to be displayed on the main map.
- **`api:inscription-table`**: Provides data for the table of inscriptions, including title, site, and date.
- **`api:inscriptions`**: Retrieves the inscriptions associated with a specific site.
- **`api:variants`**: Fetches text variants for the side-by-side comparison view.
- **`api:characters_thumbnails` / `api:characters_new`**: Provides data about Chinese characters, including images and metadata.
- **`api:places`**: Returns a list of geographical places.
- **`api:research-articles`**: Provides a list of research articles.
- **`api:bibliography`**: Serves bibliographic data.
- **`api:persons`**: Provides information about historical and modern persons.
- **Facet Functions**: A series of functions (e.g., `api:article-facets`, `api:catalog-facets`) that provide data for filtering and faceting search results.

Each of these functions queries the eXist-db and returns the data in a format that can be consumed by the frontend components.

### 4.2. Data Sources

The application's data is stored in several collections within the eXist-db. These collections are configured in `modules/config.xqm` and are accessed by the custom API functions. The main data collections are:

- **`data-docs`**: Contains the primary TEI documents.
- **`data-publication`**: Contains publication-related TEI documents.
- **`data-catalog`**: Holds catalog records for the inscriptions and other objects.
- **`data-biblio`**: Stores bibliographic data in MODS format.
- **`data-authority`**: Contains authority files for persons, places, etc.

## 5. How-To Guides

This section provides step-by-step guides for common development and content management tasks.

### 5.1. How to Add a New Site to the Map

1.  **Add the site data**: Create or update the TEI or catalog file for the new site in the appropriate data collection (e.g., `data/text/`). Ensure that the file contains the necessary metadata, including the site's coordinates in a `<geo>` element.
2.  **Update the site list**: In `modules/custom-api.xql`, add the new site's ID to the `$api:SITES` variable. This will include the site in the list of sites to be displayed on the map.
3.  **Rebuild and deploy**: Rebuild the application `.xar` file and deploy it to your eXist-db instance.

### 5.2. How to Modify the Appearance of a Component

1.  **Identify the component**: Use your browser's developer tools to inspect the component you want to modify and identify its HTML tag and CSS classes.
2.  **Add custom styles**: Open `resources/css/stonesutras-theme.css` and add your custom CSS rules to target the component. You can override existing styles or add new ones.
3.  **Rebuild and deploy**: Rebuild the application and deploy it to see your changes.

### 5.3. How to Add a New API Endpoint

1.  **Define the function**: Open `modules/custom-api.xql` and define a new XQuery function that will serve as your API endpoint. The function should take a `$request` map as a parameter and return the data you want to expose.
2.  **Add routing (if necessary)**: For complex routing, you might need to add a new route in `controller.xql`. However, for simple cases, TEI Publisher's default routing might be sufficient.
3.  **Call the endpoint from the frontend**: In your HTML template, use a `pb-load` component or a custom script to call the new API endpoint.
4.  **Rebuild and deploy**: Rebuild and deploy the application to make the new endpoint available.
