# Sketch Flow

**유연하고 강력한 Flutter 스케치 플러그인**  
심플한 UI와 다양한 내보내기 기능으로 손쉽게 그리기 앱을 만들어보세요.



## 🚀 주요기능

#### 간편한 `SketchController`  
  - 단 몇 줄의 코드로 그리기 기능을 앱에 추가 가능
  - 도구 선택, 실행 취소/재실행, 내보내기까지 한 번에 관리

#### 다양한 내보내기 지원
- `PNG`: 고해상도 이미지 추출
- `SVG`: 벡터 그래픽으로 확장성 있는 저장
- `JSON`: 정확한 좌표 데이터를 저장 및 복원

#### 세련된 기본 UI 포함
- 기본 제공되는 상단/하단 바는 깔끔하고 직관적인 디자인
- 별도 커스터마이징 없이 바로 사용 가능

## 🖼️ 미리보기  
웹에서 테스트 해보기: [바로가기](https://sketch-flow-ashy.vercel.app/)  
예제 코드 보기: [main.dart](https://github.com/JunYeong0314/sketch_flow/blob/main/example/lib/main.dart)

<p align="center">
<img width = "24%" src='https://github.com/user-attachments/assets/d9dcbc12-3d7b-4b3d-a047-34608f89452a' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/9f5f8d92-d02e-4768-ae37-bba670bae995' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/1416e050-d1fe-4a60-a733-5c392ecf2581' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/2eb33ff3-3fa4-4c9a-871a-c81320369860' border='0'>
</p>

## 📒 핵심 구성 요소
| Components                              | Description                                                        |
| ---------------------------------- | --------------------------------------------------------- |
| `SketchController`                 | **(필수)** 그리기 상태를 관리하는 핵심 컨트롤러. PNG/SVG/JSON으로 데이터 추출 가능 |
| `SketchBoard`                      | **(필수)** 사용자 입력(드로잉, 지우기 등)을 처리하는 메인 캔버스 위젯                         |
| `SketchTopBar` / `SketchBottomBar` | **(선택)** 기본 제공되는 상단/하단 도구바 UI 구성요소                             |


## ✍️ 사용방법
#### 패키지 설치
- `pubspec.yaml`에 추가:
```dart
dependencies:
  sketch_flow: ^latest_version
```

#### `SketchController` 및 `SketchBoard` 설정
- `SketchController`는 그려진 데이터를 관리하는 핵심 클래스입니다.  
이 컨트롤러를 SketchBoard에 전달하면 사용자 입력을 처리하고 필요한 정보를 추출하거나 다시 로드할 수 있습니다.
```dart
final SketchController _controller = SketchController();
```

- PNG로 이미지를 추출하거나 화면을 저장하려면 `SketchBoard`에서 `GlobalKey`를 설정해야 합니다.  
이 키는 내부적으로 RepaintBoundary에 연결되어 있으며 이미지를 캡처하는 데 사용됩니다.
```dart
final GlobalKey _repaintKey = GlobalKey();
```

- `GlobalKey`를 생성했다면 `SketchBoard`에 전달합니다:
```dart
SketchBoard(
  controller: _controller,
  repaintKey: _repaintKey,
)
```
#### (선택) `SketchTopBar` `SketchBottomBar` 사용법  
- 사용하기 쉽고 다양한 매개변수를 통해 디자인적인 요소를 커스터마이징 할 수 있습니다.
```dart
Scaffold(
  appBar: SketchTopBar(controller: _controller),
  body: SketchBoard(controller: _controller),
  bottomNavigationBar: SketchBottomBar(controller: _sketchController),
)
```
> 💡 물론 UI를 자유롭게 구성할 수 있습니다.  
> `SketchController`를 제대로 연결하면 상/하단바 없이 원하는 방식으로 UI를 디자인 할 수 있습니다.

## ✨ 내보내기 & 불러오기
#### JSON (직렬화 / 역직렬화)
- `SketchController`를 사용해 그린 데이터를 JSON에 쉽게 직렬화/역직렬화를 할 수 있습니다.:
```dart
final json = _controller.toJson(); // 직렬화

_controller.fromJson(json: json); // 역직렬화
```
#### PNG
- `SketchController`를 사용해 그린 데이터를 PNG로 쉽게 내보낼 수 있습니다.  
`pixelRatio` 매개변수를 사용해 이미지 해상도를 조절할 수 있습니다:
```dart
final Uint8List? image = await _controller.extractPNG(
  repaintKey: _repaintKey,
  pixelRatio: 2.0, // Customize resolution
);
```
#### SVG
- `SketchController`를 사용해 그림을 SVG로 쉽게 내보낼 수 있습니다.  
You can define the canvas width and height to match your needs.
```dart
final String svgCode = await _controller.extractSVG(
  width: 300.0, // Define canvas width
  height: 400.0, // Define canvas height
);
```

## 🔍 Tools Overview
| Tool Type   | Description                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------ |
| **Move**    | Enables panning and zooming of the canvas without affecting the drawings.                        |
| **Pencil**  | Draws a continuous line based on user input. Configurable stroke thickness, color, and opacity.  |
| **Brush**   | Simulates a brush-like stroke with smooth edges. Supports color and thickness customization.     |
| **Palette** | Allows users to select colors for drawing tools. |
| **Eraser**  | Erases drawings either by stroke or by area.    |



