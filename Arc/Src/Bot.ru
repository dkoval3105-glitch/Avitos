import asyncio
import logging
import os
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.types import Message
from aiogram.enums import ParseMode
from aiogram.client.default import DefaultBotProperties

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Токен бота из переменных окружения
BOT_TOKEN = os.getenv("BOT_TOKEN")
if not BOT_TOKEN:
    logger.error("Не задан BOT_TOKEN. Установите его в Secrets (Codespaces) или в .env файле.")
    exit(1)

# Инициализация бота с дефолтными свойствами
bot = Bot(token=BOT_TOKEN, default=DefaultBotProperties(parse_mode=ParseMode.HTML))
dp = Dispatcher()

@dp.message(Command("start"))
async def cmd_start(message: Message):
    await message.answer(
        "<b>🔍 Ранжировщик Авито</b>\n\n"
        "Отправьте мне поисковый запрос, и я найду лучшие предложения!\n\n"
        "Пример: <code>iPhone 15 128GB</code>\n\n"
        "Используйте команду /help для списка команд.",
    )

@dp.message(Command("help"))
async def cmd_help(message: Message):
    help_text = (
        "<b>📋 Доступные команды:</b>\n"
        "/start - начать работу\n"
        "/search [запрос] - поиск объявлений\n"
        "/help - эта справка\n\n"
        "📊 <b>Критерии ранжирования:</b>\n"
        "• Цена/качество\n"
        "• Рейтинг продавца\n"
        "• Свежесть объявления\n"
        "• Наличие фото\n"
        "• Описание\n\n"
        "⚙️ <b>Настройки:</b>\n"
        "Бот работает в тестовом режиме. "
        "Скоро появятся новые функции!"
    )
    await message.answer(help_text)

@dp.message(Command("search"))
async def cmd_search(message: Message):
    try:
        query = message.text.split(maxsplit=1)[1]
    except IndexError:
        await message.answer(
            "Укажите поисковый запрос: <code>/search iPhone 15</code>"
        )
        return

    await message.answer(f"🔎 Ищу <b>{query}</b>...")
    await asyncio.sleep(1)

    # Пример результатов (заглушка)
    results = [
        {
            "title": "iPhone 15 Pro 128GB",
            "price": 89990,
            "rating": 4.8,
            "city": "Москва",
            "date": "2024-01-15",
            "url": "https://www.avito.ru/moskva/telefony/iphone_15_pro_128gb_123456",
            "photos": 5,
            "description": "Новый, в коробке, гарантия"
        },
        {
            "title": "iPhone 14 256GB",
            "price": 69990,
            "rating": 4.5,
            "city": "Санкт-Петербург",
            "date": "2024-01-10",
            "url": "https://www.avito.ru/spb/telefony/iphone_14_256gb_123457",
            "photos": 3,
            "description": "Отличное состояние, без царапин"
        }
    ]

    # Простой алгоритм ранжирования
    for ad in results:
        price_norm = 1 / (ad["price"] / 100000)
        rating_norm = ad["rating"] / 5
        ad["score"] = round(price_norm * 0.6 + rating_norm * 0.4, 2)

    results.sort(key=lambda x: x["score"], reverse=True)

    # Отправляем результаты
    for i, ad in enumerate(results[:3], 1):
        text = (
            f"{i}. <a href='{ad['url']}'>{ad['title']}</a>\n"
            f"💰 <b>Цена:</b> {ad['price']} ₽\n"
            f"⭐ <b>Рейтинг:</b> {ad['rating']}/5\n"
            f"📍 <b>Город:</b> {ad['city']}\n"
            f"📅 <b>Обновлено:</b> {ad['date']}\n"
            f"🏷️ <b>Скор:</b> {ad['score']}"
        )
        await message.answer(text)

    await message.answer(
        f"✅ Найдено {len(results)} объявлений. Показаны лучшие 3.\n\n"
        "В будущем здесь будет реальный поиск по Авито!",
        reply_markup=types.InlineKeyboardMarkup(
            inline_keyboard=[[
                types.InlineKeyboardButton(text="📊 Показать все", callback_data="show_all"),
                types.InlineKeyboardButton(text="⚙️ Настроить", callback_data="settings")
            ]]
        )
    )

@dp.callback_query(lambda c: c.data == "show_all")
async def show_all(callback: types.CallbackQuery):
    await callback.answer("Скоро будет реализовано!")

@dp.callback_query(lambda c: c.data == "settings")
async def show_settings(callback: types.CallbackQuery):
    await callback.answer("Настройки будут доступны позже!")

async def main():
    logger.info("Запуск бота...")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
