#!/bin/bash
# ==============================================================================
# Скрипт повного налаштування Python-середовища та Vim
# Автор: Wendors
# Версія: 2.0
# ==============================================================================

set -e

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функції для кольорового виводу
error() { echo -e "${RED}❌ $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
info() { echo -e "${BLUE}📝 $1${NC}"; }
step() { echo -e "${BLUE}🚀 $1${NC}"; }

# ==============================================================================
# ПОЧАТОК СКРИПТА
# ==============================================================================

echo "================================================================"
echo "🛠️  ПОВНА ІНСТАЛЯЦІЯ PYTHON ТА VIM СЕРЕДОВИЩА"
echo "================================================================"

# Перевірка прав
if [ "$EUID" -eq 0 ]; then
    error "Не запускайте скрипт під root!"
    exit 1
fi

# Перевірка дистрибутива
if ! command -v apt &> /dev/null; then
    error "Цей скрипт працює тільки на Debian/Ubuntu"
    exit 1
fi

# ==============================================================================
# КРОК 1: ОНОВЛЕННЯ СИСТЕМИ
# ==============================================================================
step "Оновлюємо систему та встановлюємо базові пакети..."

sudo apt update
sudo apt upgrade -y

# Встановлення основних залежностей
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    ncurses-dev \
    libgtk-3-dev \
    libatk1.0-dev \
    libcairo2-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    ruby-dev \
    lua5.3 \
    liblua5.3-dev \
    libperl-dev \
    clang \
    nodejs \
    npm

success "Системні пакети встановлено"

# ==============================================================================
# КРОК 2: ВИБІР МЕТОДУ ВСТАНОВЛЕННЯ VIM
# ==============================================================================
echo ""
info "Оберіть спосіб встановлення Vim:"
echo "1) Швидкий (з системних пакетів) - рекомендовано"
echo "2) Повний (компіляція з исходників) - для досвідчених"
read -p "Ваш вибір [1/2]: " VIM_CHOICE

case $VIM_CHOICE in
    1)
        # Швидке встановлення з пакетів
        step "Встановлюємо Vim з системних пакетів..."
        sudo apt install -y vim-gtk3 neovim

        # Перевірка підтримки clipboard
        if vim --version | grep -q "+clipboard"; then
            success "Vim встановлено з підтримкою clipboard"
        else
            warning "Vim встановлено, але clipboard може не працювати"
        fi
        ;;
    2)
        # Повне встановлення з исходників
        step "Компілюємо Vim з исходників..."

        # Створення тимчасової директорії
        BUILD_DIR="/tmp/vim_build"
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"

        # Завантаження та розпакування Vim
        if [ ! -d "vim" ]; then
            git clone https://github.com/vim/vim.git
        fi

        cd vim
        git pull
        git checkout master

        # Конфігурація та компіляція
        step "Конфігуруємо Vim..."
        ./configure \
            --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk3 \
            --enable-cscope \
            --prefix=/usr/local \
            --with-x \
            --enable-clipboard \
            --with-xterm_clipboard

        step "Компілюємо Vim..."
        make -j$(nproc)

        step "Встановлюємо Vim..."
        sudo make install

        # Повернення до робочої директорії
        cd -

        # Перевірка результатів
        if vim --version | grep -q "+clipboard"; then
            success "Vim успішно скомпільовано з підтримкою clipboard"
        else
            error "Проблема з компіляцією Vim"
            exit 1
        fi
        ;;
    *)
        error "Невірний вибір"
        exit 1
        ;;
esac

# ==============================================================================
# КРОК 3: СТВОРЕННЯ ВІРТУАЛЬНОГО СЕРЕДОВИЩА PYTHON
# ==============================================================================
step "Створюємо віртуальне середовище Python..."

read -p "Введіть назву директорії для venv [.venv]: " VENV_DIR
VENV_DIR=${VENV_DIR:-.venv}
VENV_PATH="$HOME/$VENV_DIR"

# Перевірка та створення venv
if [ -d "$VENV_PATH" ]; then
    warning "Директорія $VENV_PATH вже існує"
    read -p "Перестворити? [y/N]: " RECREATE
    if [[ $RECREATE =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_PATH"
        python3 -m venv "$VENV_PATH"
        success "Віртуальне середовище перестворено"
    else
        info "Використовуємо існуюче середовище"
    fi
else
    python3 -m venv "$VENV_PATH"
    success "Віртуальне середовище створено у $VENV_PATH"
fi

# ==============================================================================
# КРОК 4: ВСТАНОВЛЕННЯ PYTHON-БІБЛІОТЕК
# ==============================================================================
step "Встановлюємо Python-бібліотеки..."

# Активуємо середовище
source "$VENV_PATH/bin/activate"

# Оновлюємо pip
pip install --upgrade pip

# Встановлення бібліотек з файлу або базового набору
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    success "Бібліотеки з requirements.txt встановлено"
elif [ -f "piplist.txt" ]; then
    pip install -r piplist.txt
    success "Бібліотеки з piplist.txt встановлено"
else
    # Базовий набір для розробки
    pip install \
        black \
        flake8 \
        isort \
        pylint \
        mypy \
        pytest \
        numpy \
        pandas \
        requests \
        jupyter
    success "Базові бібліотеки для розробки встановлено"
fi

# Деактивуємо середовище
deactivate

# ==============================================================================
# КРОК 5: НАЛАШТУВАННЯ VIM
# ==============================================================================
step "Налаштовуємо Vim..."

# Встановлення vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug встановлено"
else
    info "vim-plug вже встановлений"
fi

# Копіювання .vimrc з резервною копією
if [ -f "vimrc" ]; then
    if [ -f "$HOME/.vimrc" ]; then
        cp "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"
        info "Зроблено резервну копію існуючого .vimrc"
    fi

    cp "vimrc" "$HOME/.vimrc"
    success ".vimrc скопійовано"
else
    warning "Файл vimrc не знайдено в поточній директорії"

    # Створення базового .vimrc
    cat > "$HOME/.vimrc" << 'EOF'
" Базовий .vimrc
set nocompatible
filetype off

set number
set relativenumber
syntax on
set encoding=utf-8
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a

call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

nnoremap <C-n> :NERDTreeToggle<CR>
EOF

    success "Створено базовий .vimrc"
fi

# Встановлення плагінів
step "Встановлюємо плагіни Vim..."
vim +PlugInstall +qall

# ==============================================================================
# КРОК 6: ДОДАТКОВІ ІНСТРУМЕНТИ
# ==============================================================================
step "Встановлюємо додаткові інструменты..."

# Встановлення LSP-серверів
info "Встановлюємо LSP-сервери..."

# Python LSP
sudo apt install -y nodejs npm
sudo npm install -g pyright

# Інші LSP-сервери
sudo npm install -g \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted \
    prettier \
    eslint

# Встановлення fzf
if ! command -v fzf &> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# ==============================================================================
# КРОК 7: ФІНАЛЬНІ НАЛАШТУВАННЯ
# ==============================================================================
step "Фінальні налаштування..."

# Додавання шляху до venv в .bashrc
if ! grep -q "$VENV_PATH/bin" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Python virtual environment" >> "$HOME/.bashrc"
    echo "export PATH=\"$VENV_PATH/bin:\$PATH\"" >> "$HOME/.bashrc"
    success "Шлях до venv додано в .bashrc"
fi

# Створення директорії для undo файлів
mkdir -p ~/.vim/undodir

# ==============================================================================
# ЗАВЕРШЕННЯ
# ==============================================================================
echo ""
echo "================================================================"
success "ІНСТАЛЯЦІЮ ЗАВЕРШЕНО!"
echo "================================================================"
echo ""
echo "📋 ЩО БУЛО ЗРОБЛЕНО:"
echo "   ✅ Оновлено систему та встановлено базові пакети"
echo "   ✅ Встановлено Vim з підтримкою clipboard"
echo "   ✅ Створено віртуальне середовище: $VENV_PATH"
echo "   ✅ Встановлено Python-бібліотеки"
echo "   ✅ Налаштовано .vimrc та плагіни"
echo "   ✅ Встановлено LSP-сервери"
echo ""
echo "🎯 НАСТУПНІ КРОКИ:"
echo "   1. Перезапустіть термінал: source ~/.bashrc"
echo "   2. Активуйте середовище: source $VENV_PATH/bin/activate"
echo "   3. Перевірте Vim: vim --version | grep clipboard"
echo "   4. Перевірте плагіни: vim +PlugStatus"
echo ""
echo "🔧 ДОДАТКОВІ КОМАНДИ:"
echo "   - Активувати середовище: source $VENV_PATH/bin/activate"
echo "   - Деактивувати середовище: deactivate"
echo "   - Оновити плагіни Vim: vim +PlugUpdate"
echo "   - Перевірити LSP: vim +CocList services"
echo ""
echo "================================================================"

# Фінальна перевірка
if command -v vim &> /dev/null && vim --version | grep -q "+clipboard"; then
    success "Vim готовий до роботи з підтримкою clipboard!"
else
    warning "Vim встановлено, але clipboard може не працювати"
fi
