#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Скрипт повного налаштування Python-середовища та Vim для Termux
# Автор: Wendors
# Версія: 1.0
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
echo "🛠️  ПОВНА ІНСТАЛЯЦІЯ PYTHON ТА VIM СЕРЕДОВИЩА ДЛЯ TERMUX"
echo "================================================================"

# Перевірка що ми в Termux
if [ ! -d "/data/data/com.termux" ]; then
    error "Цей скрипт призначений тільки для Termux"
    exit 1
fi

# ==============================================================================
# КРОК 1: ОНОВЛЕННЯ СИСТЕМИ
# ==============================================================================
step "Оновлюємо систему та встановлюємо базові пакети..."

pkg update -y
pkg upgrade -y

# Встановлення основних залежностей
pkg install -y \
    python \
    python-pip \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    ncurses \
    vim \
    neovim \
    clang \
    nodejs \
    npm \
    openssh \
    rsync

success "Системні пакети встановлено"

# ==============================================================================
# КРОК 2: НАЛАШТУВАННЯ VIM
# ==============================================================================
step "Налаштовуємо Vim для Termux..."

# Перевірка встановлення Vim
if command -v vim &> /dev/null; then
    success "Vim встановлено успішно"
else
    error "Проблема з встановленням Vim"
    exit 1
fi

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
        python -m venv "$VENV_PATH"
        success "Віртуальне середовище перестворено"
    else
        info "Використовуємо існуюче середовище"
    fi
else
    python -m venv "$VENV_PATH"
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
    # Встановлюємо тільки сумісні з Termux пакети
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
        beautifulsoup4 \
        lxml \
        jedi
    success "Бібліотеки з piplist.txt встановлено (Termux-сумісні)"
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
        jedi
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

    # Створюємо Termux-адаптовану версію vimrc
    cp "vimrc" "$HOME/.vimrc"
    
    # Оновлюємо шлях до Python для Termux
    if grep -q "/home/wandors/.virtualvenv/bin/python3" "$HOME/.vimrc"; then
        sed -i "s|/home/wandors/.virtualvenv/bin/python3|$VENV_PATH/bin/python|g" "$HOME/.vimrc"
    fi
    
    success ".vimrc скопійовано та адаптовано для Termux"
else
    warning "Файл vimrc не знайдено в поточній директорії"

    # Створення базового .vimrc для Termux
    cat > "$HOME/.vimrc" << 'EOF'
" Базовий .vimrc для Termux
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
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
call plug#end()

nnoremap <C-n> :NERDTreeToggle<CR>
EOF

    success "Створено базовий .vimrc для Termux"
fi

# Встановлення плагінів
step "Встановлюємо плагіни Vim..."
vim +PlugInstall +qall

# ==============================================================================
# КРОК 6: ДОДАТКОВІ ІНСТРУМЕНТИ
# ==============================================================================
step "Встановлюємо додаткові інструменти..."

# Встановлення LSP-серверів
info "Встановлюємо LSP-сервери..."

# Python LSP
npm install -g pyright 2>/dev/null || warning "Pyright не вдалося встановити (можливо недостатньо пам'яті)"

# Інші корисні інструменти
npm install -g \
    typescript \
    prettier 2>/dev/null || warning "Деякі npm пакети не вдалося встановити"

# Встановлення fzf
if ! command -v fzf &> /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
    success "fzf встановлено"
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

# Додавання корисних аліасів для Termux
if ! grep -q "# Termux Python Dev Aliases" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

# Termux Python Dev Aliases
alias vimpy='vim'
alias activate='source ~/.venv/bin/activate'
alias py='python'
alias ipy='python -i'
EOF
    success "Додано корисні аліаси"
fi

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
echo "   ✅ Встановлено Vim для Termux"
echo "   ✅ Створено віртуальне середовище: $VENV_PATH"
echo "   ✅ Встановлено Python-бібліотеки"
echo "   ✅ Налаштовано .vimrc та плагіни"
echo "   ✅ Встановлено додаткові інструменти"
echo ""
echo "🎯 НАСТУПНІ КРОКИ:"
echo "   1. Перезапустіть термінал: source ~/.bashrc"
echo "   2. Активуйте середовище: source $VENV_PATH/bin/activate"
echo "   3. Перевірте Vim: vim --version"
echo "   4. Перевірте плагіни: vim +PlugStatus"
echo ""
echo "🔧 ДОДАТКОВІ КОМАНДИ:"
echo "   - Активувати середовище: source $VENV_PATH/bin/activate"
echo "   - Деактивувати середовище: deactivate"
echo "   - Оновити плагіни Vim: vim +PlugUpdate"
echo "   - Швидко активувати: activate (аліас)"
echo ""
echo "⚠️  ОСОБЛИВОСТІ TERMUX:"
echo "   - GUI плагіни не підтримуються"
echo "   - Деякі пакети можуть працювати повільніше"
echo "   - Рекомендується використовувати NeoVim для кращої продуктивності"
echo ""
echo "================================================================"

# Фінальна перевірка
if command -v vim &> /dev/null; then
    success "Vim готовий до роботи в Termux!"
else
    error "Виникла проблема з встановленням Vim"
    exit 1
fi
