# MediaTrack

Aplicativo desenvolvido em Flutter para gerenciar e acompanhar o progresso de séries, leituras e outros conteúdos similares. Ele atende a qualquer formato que utilize temporadas, capítulos, episódios ou etapas, permitindo uma organização prática e intuitiva do consumo de conteúdo.

## 🎯 Funcionalidades

- **Múltiplos tipos de mídia**: Suporta séries, filmes, livros, jogos, podcasts e animes
- **Acompanhamento de progresso**: Rastreie temporadas, episódios, páginas e capítulos
- **Avaliações**: Adicione avaliações de 0 a 5 estrelas para cada item
- **Notas**: Adicione notas pessoais sobre cada conteúdo
- **Estatísticas**: Visualize estatísticas sobre seus itens e progresso geral
- **Filtros**: Filtre itens por tipo de mídia
- **Interface moderna**: UI bonita e responsiva com suporte a tema claro/escuro
- **Persistência de dados**: Dados salvos localmente usando Hive

## 📱 Tipos de Mídia Suportados

1. **Série**: Temporadas e episódios
2. **Filme**: Status completo/não completo
3. **Livro**: Páginas e capítulos
4. **Jogo**: Status completo/em progresso
5. **Podcast**: Episódios
6. **Anime**: Temporadas e episódios

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK
- Um dispositivo físico ou emulador Android/iOS

### Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd MediaTrack
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Gere os arquivos necessários do Hive (se necessário):
```bash
flutter pub run build_runner build
```

4. Execute o aplicativo:
```bash
flutter run
```

## 📦 Dependências Principais

- `hive` e `hive_flutter`: Persistência de dados local
- `intl`: Formatação de datas
- `flutter_slidable`: Componentes deslizáveis (preparado para futuras funcionalidades)

## 🎨 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── models/
│   └── media_item.dart      # Modelo de dados para itens de mídia
├── services/
│   └── media_service.dart   # Serviço para gerenciar dados
└── screens/
    ├── home_screen.dart              # Tela principal com lista de itens
    ├── media_detail_screen.dart      # Tela de detalhes do item
    └── add_edit_media_screen.dart    # Tela para adicionar/editar itens
```

## 📝 Como Usar

1. **Adicionar um item**: Toque no botão "+" na tela principal e preencha as informações
2. **Visualizar detalhes**: Toque em qualquer item da lista para ver mais detalhes
3. **Editar**: Na tela de detalhes, toque no ícone de edição no canto superior direito
4. **Excluir**: Na tela de detalhes, use o botão "Excluir" na parte inferior
5. **Filtrar**: Use o menu de filtros no canto superior direito da tela principal

## 🔧 Desenvolvimento

O aplicativo utiliza:
- **Material Design 3** para a interface
- **Hive** para armazenamento local de dados
- **Arquitetura simples** com separação de modelos, serviços e telas

## 📄 Licença

Este projeto é de código aberto e está disponível para uso pessoal e educacional.
