# Sketch Flow
<p align="center">
<img width = "60%" src='https://github.com/user-attachments/assets/f7d55a46-9669-4470-a70e-cf0effb293a7' border='0' />
</p>


[English](https://github.com/JunYeong0314/sketch_flow/edit/main/README.md) / [한국어](https://github.com/JunYeong0314/sketch_flow/blob/main/README-KO.md)  
**유연하고 강력한 Flutter 스케치 플러그인**  
심플한 UI와 다양한 내보내기 기능으로 손쉽게 그리기 앱을 만들어보세요.



## 주요기능

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

## 미리보기  
웹에서 테스트 해보기: [바로가기](https://fasoo-digitalpage.github.io/sketch_flow/)  
예제 코드 보기: [main.dart](https://github.com/fasoo-digitalpage/sketch_flow/blob/main/example/lib/main.dart)  
sketch_flow를 활용한 예제 프로젝트 보러가기: [sketch_flow_example](https://github.com/JunYeong0314/sketch_flow_example)

<p align="center">

<img width = "24%" src='https://github.com/user-attachments/assets/92eff9fe-c1f0-435a-970a-b0bf78f24b34' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/22cbdbbd-86e8-47a7-9880-2d48bbdb0e0f' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/d455aa41-d42c-456f-9011-fdc03e279aa7' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/81e68979-80dc-4b7e-88b2-12fe60c66435' border='0'>
</p>

## 핵심 구성 요소
| Components                              | Description                                                        |
| ---------------------------------- | --------------------------------------------------------- |
| `SketchController`                 | **(필수)** 그리기 상태를 관리하는 핵심 컨트롤러. PNG/SVG/JSON으로 데이터 추출 가능 |
| `SketchBoard`                      | **(필수)** 사용자 입력(드로잉, 지우기 등)을 처리하는 메인 캔버스 위젯                         |
| `SketchTopBar` / `SketchBottomBar` | **(선택)** 기본 제공되는 상단/하단 도구바 UI 구성요소                             |

## 아키텍처
<p align="center">
<img width = "70%" src='https://github.com/user-attachments/assets/248da299-3e7b-4585-b7f0-f534daa731e4' border='0'>
</p>

## 사용방법
#### 패키지 설치
- `pubspec.yaml`에 추가: [최신 버전 확인](https://pub.dev/packages/sketch_flow/versions)
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

## 내보내기 & 불러오기
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
필요에 맞게 캔버스 너비와 높이를 지정 할 수 있습니다.
```dart
final String svgCode = await _controller.extractSVG(
  width: 300.0, // Define canvas width
  height: 400.0, // Define canvas height
);
```

## 도구 개요
| 도구 유형   | 설명                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------ |
| **Move**    | 도면에 영향을 주지 않고 확대/축소 및 스크롤 할 수 있습니다.                        |
| **Pencil**  | 사용자 입력에 따라 선을 그립니다. 획의 두께, 색상, 불투명도를 설정 할 수 있습니다.  |
| **Brush**   | 부드러운 붓 효과가 적용된 선을 그립니다. 획의 두께, 색상, 불투명도를 설정 할 수 있습니다.     |
| **Highlighter**  | 형광펜과 유사한 반투명 선을 그립니다. 실제 평광펜 효과를 적용하기 위해 사전에 정의된 낮은 불투명도와 중간두께를 제공합니다.    |
| **Palette** | 사용자가 그림 도구의 색상을 선택 할 수 있습니다. |
| **Eraser**  | 획 지우개, 영역 지우개를 선택 할 수 있으며 그림을 지웁니다.    |
| **Line**  | 획 지우개, 영역 지우개를 선택 할 수 있으며 그림을 지웁니다.    |
| **Rectangle**  | 첫 번째 및 마지막 터치 포인트로 정의된 직사각형을 그립니다.    |
| **Circle**  | 첫 번째 터치와 마지막 터치 포인트로 경계가 있는 원을 그립니다.    |



