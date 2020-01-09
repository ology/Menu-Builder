CREATE TABLE account (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE meal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    account_id INTEGER NOT NULL
);

CREATE TABLE meal_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    meal_id INTEGER NOT NULL
);

CREATE TABLE menu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    meal_id INTEGER NOT NULL
);

CREATE TABLE menu_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    meal_item_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    menu_id INTEGER NOT NULL
);

CREATE TABLE item_detail (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_id INTEGER NOT NULL,
    ingredients TEXT NOT NULL,
    instructions TEXT
);
