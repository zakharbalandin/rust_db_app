use iced::{
    Application, Element, Settings, Theme, Command,
    widget::{Column, Text, Button, Container, Scrollable, Row, TextInput},
    Color, Length,
};
use tokio_postgres::{NoTls, Error as PgError};
use std::fmt;
use std::env;
use serde::{Deserialize, Serialize};
use chrono::Utc;

#[derive(Debug, Clone)]
struct DbError(String);

impl From<PgError> for DbError {
    fn from(error: PgError) -> Self {
        DbError(error.to_string())
    }
}

impl fmt::Display for DbError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct DbConfig {
    host: String,
    port: String,
    dbname: String,
    user: String,
    password: String,
}

impl DbConfig {
    fn new() -> Self {
        Self {
            host: env::var("DB_HOST").unwrap_or_else(|_| "localhost".to_string()),
            port: env::var("DB_PORT").unwrap_or_else(|_| "5432".to_string()),
            dbname: env::var("DB_NAME").unwrap_or_else(|_| "music_db".to_string()),
            user: env::var("DB_USER").unwrap_or_else(|_| "postgres".to_string()),
            password: env::var("DB_PASSWORD").unwrap_or_else(|_| "postgres".to_string()),
        }
    }

    fn connection_string(&self) -> String {
        format!(
            "host={} port={} dbname={} user={} password={}",
            self.host, self.port, self.dbname, self.user, self.password
        )
    }
}

struct MusicApp {
    albums: Vec<String>,
    error: Option<String>,
    loading: bool,
    config: DbConfig,
    new_genre_name: String,
    status_message: Option<String>,
}

#[derive(Debug, Clone)]
enum Message {
    LoadAlbums,
    AlbumsLoaded(Result<Vec<String>, DbError>),
    AddGenre,
    GenreAdded(Result<(), DbError>),
    UpdateGenreName(String),
}

impl Application for MusicApp {
    type Executor = iced::executor::Default;
    type Message = Message;
    type Theme = Theme;
    type Flags = ();

    fn new(_flags: ()) -> (Self, Command<Self::Message>) {
        let config = DbConfig::new();
        (
            Self {
                albums: Vec::new(),
                error: None,
                loading: false,
                config,
                new_genre_name: String::new(),
                status_message: None,
            },
            Command::none(),
        )
    }

    fn title(&self) -> String {
        String::from("Music Database GUI")
    }

    fn update(&mut self, message: Self::Message) -> Command<Self::Message> {
        match message {
            Message::LoadAlbums => {
                self.loading = true;
                self.error = None;
                let config = self.config.clone();
                Command::perform(fetch_albums(config), |result| {
                    Message::AlbumsLoaded(result.map_err(DbError::from))
                })
            }
            Message::AlbumsLoaded(Ok(albums)) => {
                self.albums = albums;
                self.loading = false;
                Command::none()
            }
            Message::AlbumsLoaded(Err(e)) => {
                self.error = Some(e.to_string());
                self.loading = false;
                Command::none()
            }
            Message::AddGenre => {
                if self.new_genre_name.trim().is_empty() {
                    self.error = Some("Please enter a genre name".to_string());
                    return Command::none();
                }
self.loading = true;
                self.error = None;
                let config = self.config.clone();
                let genre_name = self.new_genre_name.clone();

                Command::perform(
                    add_genre(
                        config,
                        genre_name,
                    ),
                    |result| {
                        Message::GenreAdded(result.map_err(DbError::from))
                    },
                )
            }
            Message::GenreAdded(Ok(_)) => {
                self.loading = false;
                self.status_message = Some("Genre added successfully!".to_string());
                self.new_genre_name.clear();
                Command::none()
            }
            Message::GenreAdded(Err(e)) => {
                self.loading = false;
                self.error = Some(format!("Failed to add genre: {}", e));
                Command::none()
            }
            Message::UpdateGenreName(name) => {
                self.new_genre_name = name;
                Command::none()
            }
        }
    }

    fn view(&self) -> Element<'_, Self::Message> {
        let mut content = Column::new().padding(20).spacing(15);

        // Заголовок
        content = content.push(Text::new("Music Database").size(24).style(iced::theme::Text::Color(Color::from_rgb(0.2, 0.2, 0.8))));

        // Форма добавления жанра
        let add_genre_form = Column::new().spacing(10)
            .push(Text::new("Add New Genre").size(18))
            .push(TextInput::new("Genre Name", &self.new_genre_name)
                .on_input(Message::UpdateGenreName)
                .padding(8)
                .width(Length::Fixed(300.0)))
            .push(Button::new(Text::new("Add Genre"))
                .padding([8, 16])
                .on_press(Message::AddGenre)
                .style(iced::theme::Button::Primary));

        content = content.push(Container::new(add_genre_form).padding(15).style(iced::theme::Container::Box));

        // Кнопка загрузки альбомов
        let load_button = if self.loading {
            Button::new(Text::new("Loading...").style(iced::theme::Text::Color(Color::from_rgb(0.5, 0.5, 0.5))))
                .style(iced::theme::Button::Secondary)
        } else {
            Button::new(Text::new("Load Albums"))
                .padding([8, 16])
                .on_press(Message::LoadAlbums)
                .style(iced::theme::Button::Primary)
        };

        content = content.push(Row::new().push(load_button).spacing(10));

        // Статусные сообщения
        if let Some(msg) = &self.status_message {
            content = content.push(Container::new(
                Text::new(msg).style(iced::theme::Text::Color(Color::from_rgb(0.0, 0.7, 0.0)))
            ).padding(10));
        }

        if let Some(err) = &self.error {
            content = content.push(Container::new(
                Column::new()
                    .push(Text::new("Error:").style(iced::theme::Text::Color(Color::from_rgb(1.0, 0.0, 0.0))))
                    .push(Text::new(err).size(14))
            ).padding(10).style(iced::theme::Container::Box));
        }

        // Список альбомов
        content = content.push(Text::new("Albums:").size(18));
let albums_list: Element<Self::Message> = if self.albums.is_empty() && !self.loading {
            Scrollable::new(Column::new().push(
                Container::new(Text::new("No albums loaded. Click 'Load Albums' to fetch data."))
                    .padding(20)
            ))
            .height(Length::Fixed(300.0))
            .into()
        } else if self.albums.is_empty() {
            Scrollable::new(Column::new().push(
                Container::new(Text::new("Loading albums..."))
                    .padding(20)
            ))
            .height(Length::Fixed(300.0))
            .into()
        } else {
            let mut album_column = Column::new().spacing(8);
            for (i, title) in self.albums.iter().enumerate() {
                album_column = album_column.push(
                    Container::new(
                        Row::new()
                            .push(Text::new(format!("{}. {}", i + 1, title)).size(16))
                            .spacing(10)
                            .align_items(iced::Alignment::Center)
                    )
                    .padding(12)
                    .width(Length::Fill)
                    .style(iced::theme::Container::Box)
                );
            }
            Scrollable::new(album_column)
                .height(Length::Fixed(300.0))
                .into()
        };

        content = content.push(albums_list);

        // Подвал с информацией
        content = content.push(
            Container::new(
                Text::new("Music Database GUI - Rust + PostgreSQL + Iced")
                    .size(12)
                    .style(iced::theme::Text::Color(Color::from_rgb(0.4, 0.4, 0.4)))
            )
            .padding(10)
            .center_x()
        );

        Container::new(content)
            .width(Length::Fill)
            .height(Length::Fill)
            .center_x()
            .into()
    }
}

async fn fetch_albums(config: DbConfig) -> Result<Vec<String>, PgError> {
    let connection_string = config.connection_string();

    match tokio_postgres::connect(&connection_string, NoTls).await {
        Ok((client, connection)) => {
            tokio::spawn(async move {
                if let Err(e) = connection.await {
                    eprintln!("connection error: {}", e);
                }
            });

            let rows = client
                .query("SELECT title FROM Albums ORDER BY release_date DESC LIMIT 50", &[])
                .await?;

            Ok(rows.iter().map(|row| row.get(0)).collect())
        }
        Err(e) => {
            eprintln!("Failed to connect to database: {}", e);
            Err(e)
        }
    }
}

async fn add_genre(
    config: DbConfig,
    genre_name: String,
) -> Result<(), PgError> {
    let connection_string = config.connection_string();

    let (client, connection) = tokio_postgres::connect(&connection_string, NoTls).await?;

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    // Добавляем жанр
    client.execute(
        "INSERT INTO Genres (name) VALUES ($1)",
        &[&genre_name],
    ).await?;

    Ok(())
}

fn main() -> iced::Result {
    // Настройки для Linux
    #[cfg(target_os = "linux")]
    {
        set_locale();
        setup_display();
    }

    println!("Starting Music Database GUI...");
    println!("Database config: host={}, dbname={}", DbConfig::new().host, DbConfig::new().dbname);

    MusicApp::run(Settings::default())
}

#[cfg(target_os = "linux")]
fn set_locale() {
    // Устанавливаем стандартную локаль UTF-8
    env::set_var("LANG", "C.UTF-8");
    env::set_var("LC_ALL", "C.UTF-8");
}
#[cfg(target_os = "linux")]
fn setup_display() {
    // Проверяем, установлен ли DISPLAY
    if env::var("DISPLAY").is_err() {
        // Пытаемся использовать стандартный DISPLAY
        env::set_var("DISPLAY", ":0");
        println!("DISPLAY not set, using default :0");
    }

    // Для работы с Wayland
    if let Ok(session_type) = env::var("XDG_SESSION_TYPE") {
        if session_type == "wayland" {
            println!("Wayland session detected. Setting up X11 fallback...");
            env::set_var("XDG_SESSION_TYPE", "x11");
            env::set_var("GDK_BACKEND", "x11");
            env::set_var("QT_QPA_PLATFORM", "xcb");
        }
    }

    // Создаем XDG_RUNTIME_DIR если его нет
    if env::var("XDG_RUNTIME_DIR").is_err() {
        let runtime_dir = "/tmp/runtime";
        std::fs::create_dir_all(runtime_dir).ok();
        env::set_var("XDG_RUNTIME_DIR", runtime_dir);
    }
}
