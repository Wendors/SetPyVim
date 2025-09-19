
#!/bin/bash
echo "🚀 Починаємо налаштування Python-середовища та Vim..."

set -e

echo "🔄 Оновлюємо систему та встановлюємо Python..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 🔹 Запит у користувача директорії для venv
read -p "📁 Введіть назву або шлях до директорії для створення venv: " VENV_DIR

# 🔹 Перевірка введення
if [ -z "$VENV_DIR" ]; then
    echo "❌ Ви не ввели директорію. Вихід."
    exit 1
fi

# 🔹 Створення venv
echo "📦 Створюємо віртуальне середовище у '$HOME/$VENV_DIR'..."
python3 -m venv "$HOME/$VENV_DIR"

# 🔹 Активація venv
echo "🟢 Активація середовища..."
source "$HOME/$VENV_DIR/bin/activate"

# 🔹 Встановлення залежностей
PIPLIST="$(pwd)/piplist.txt"
if [ -f "$PIPLIST" ]; then
    echo "📥 Встановлюємо бібліотеки з piplist.txt..."
    echo "# Шлях до каталогу: $(pwd)" >> "$PIPLIST"
    pip install --upgrade pip
    pip install -r "$PIPLIST"
else
    echo "⚠️ Файл piplist.txt не знайдено."
fi

# 🔹 Деактивація
echo "✅ Python-середовище готове!"

# 🔹 Копіювання vimrc
VIMRC="$(pwd)/vimrc"
if [ -f "$VIMRC" ]; then
    cp "$VIMRC" "$HOME/.vimrc"
    echo "📄 vimrc скопійовано до ~/.vimrc"
else
    echo "⚠️ Файл vimrc не знайдено. Пропускаємо."
fi
# 🔹 Встановлення Vim з підтримкою clipboard
echo "🛠️ Встановлюємо залежності для збірки Vim..."
sudo apt install -y \
  git build-essential ncurses-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev \
  libx11-dev libxpm-dev libxt-dev python3-dev ruby-dev lua5.3 liblua5.3-dev \
  libperl-dev cmake curl

echo "📥 Клонуємо Vim..."
git clone https://github.com/vim/vim.git
cd vim

echo "📌 Перехід на master..."
git checkout master

echo "⚙️ Конфігурація Vim..."
./configure \
  --with-features=huge \
  --enable-multibyte \
  --enable-rubyinterp=yes \
  --enable-python3interp=yes \
  --enable-perlinterp=yes \
  --enable-luainterp=yes \
  --enable-gui=gtk2 \
  --enable-cscope \
  --prefix=/usr/local \
  --with-x \
  --enable-clipboard \
  --with-xterm_clipboard

echo "🔨 Компіляція Vim..."
make -j$(nproc)
sudo make install
cd ..

echo "🔍 Перевірка clipboard:"
vim --version | grep clipboard || echo "❌ Clipboard не підтримується"
vim --version | grep xterm_clipboard || echo "❌ xterm_clipboard не підтримується"

echo "🎉 Vim встановлено!"

# 🔹 Встановлення vim-plug
echo "📦 Встановлюємо vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "🚀 Встановлюємо плагіни..."
vim +PlugInstall +qall

echo "✅ Успішно завершено!"

