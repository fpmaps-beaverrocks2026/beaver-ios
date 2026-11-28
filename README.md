# Beaver iOS

iOS 26 이상에서 사용할 수 있는 Swift 6.2 패키지입니다. Xcode의 **File → Add Package Dependencies → Add Local**에서 이 저장소를 선택한 뒤 필요한 제품을 앱 타깃에 추가합니다.

| 제품 | 컴포넌트 |
| --- | --- |
| `IndoorMapComponents` | IMDF 로더, 층별 실내 지도, 편의시설과 찜 마커, 층 선택기, 편의시설 토글, 찜 ID 저장소 |
| `BottomSheetComponents` | 길안내 스타일의 2단 바텀시트와 드래그에 따라 높이가 변하는 경로 미리보기 스타일의 바텀시트 |
| `BeaverDesignSystem` | 공통 색, 글자 크기와 간격, 둥근 모서리, 버튼, 제목 영역, 확인 카드 |

## 실내 지도

`IMDFMapLoader().load(directory:)`에 압축을 푼 IMDF 1.0.0 디렉터리를 전달합니다. 디렉터리에는 `manifest.json`과 `venue`, `level`, `footprint`, `unit`, `fixture`, `opening` GeoJSON 파일이 필요합니다. `amenity`, `section` 파일이 있으면 함께 읽습니다. 이미 구조화한 지도 데이터가 있다면 `IndoorMap`을 직접 만들 수 있습니다.

찜할 항목의 ID와 지도상의 위치를 `MapFavoritePlacement`로 전달합니다. 같은 층과 장소 ID에 있는 찜 항목은 하나의 마커와 개수 배지로 표시됩니다. 마커를 선택하면 콜백으로 항목 ID들을 받습니다. `MapFavoritesStore`를 사용할 때는 같은 저장 키를 사용하는 화면에서 한 인스턴스를 공유합니다. 기존 찜 저장소가 있다면 거기서 읽은 ID 집합을 직접 전달할 수 있습니다.

```swift
import IndoorMapComponents
import SwiftUI

struct VenueMap: View {
    let map: IndoorMap
    let placements: [MapFavoritePlacement]
    let onSelectItems: (Set<String>) -> Void

    @State private var floorID: UUID?
    @State private var showsAmenities = false
    @State private var favorites = MapFavoritesStore(storageKey: "beaver.map.favorites")

    var body: some View {
        IndoorMapView(
            map: map,
            floorID: floorID,
            markers: IndoorMapMarker.amenities(in: map)
                + IndoorMapMarker.favorites(placements, favoriteIDs: favorites.favoriteIDs),
            showsAmenities: showsAmenities,
            onSelectFavorite: { onSelectItems($0.favoriteIDs) }
        )
        .overlay(alignment: .bottomLeading) {
            VStack {
                IndoorMapAmenitiesToggle(showsAmenities: $showsAmenities)
                IndoorMapFloorPicker(floors: map.floors, selection: $floorID)
            }
            .padding()
        }
    }
}
```

항목의 찜 버튼에는 `favorites.toggle(itemID)` 또는 `favorites.setFavorite(_:for:)`를 연결합니다. 편의시설을 숨긴 상태에서도 계단, 엘리베이터, 찜은 표시됩니다. 앱의 지도 데이터와 항목 위치는 호출부에서 공급합니다. 지도 마커는 시설 종류별로 기본 SF Symbols를 사용합니다.

## 바텀시트

`BottomSheet`의 두 높이에는 손잡이 영역이 포함됩니다. 오버레이가 하단 safe area까지 내려가는 레이아웃에서는 `bottomInset`으로 그 값을 전달합니다.

```swift
import BottomSheetComponents
import SwiftUI

struct MapWithSheet<MapContent: View, Details: View>: View {
    let map: MapContent
    let details: Details
    @State private var isExpanded = false

    var body: some View {
        map.overlay(alignment: .bottom) {
            BottomSheet(isExpanded: $isExpanded, collapsedHeight: 120, expandedHeight: 340) {
                details
            }
        }
    }
}
```

경로 미리보기 스타일에는 `ResizableBottomSheet`를 사용합니다. `BottomSheetPresentation`을 바인딩하고 전체 레이아웃 크기와 해당 safe area를 전달합니다. 본문, 하단 버튼, 펼쳤을 때의 배경은 각각 View로 전달합니다. 접혔을 때 층 배지 등을 표시하려면 `accessory`를 추가합니다. 본문이 스크롤되는 경우 `isContentAtTop`을 스크롤 위치와 동기화하면 본문이 맨 위에 있을 때 아래로 드래그해 시트를 접을 수 있습니다. `onCoveredHeightChange`로 접힌 영역의 높이를 받아 지도 초기 표시와 층 전환에 사용하는 뷰포트 여백으로 전달할 수 있습니다.

## 디자인 시스템

`import BeaverDesignSystem`으로 가져온 뒤 `BeaverUI`에서 색상, 글자, 간격과 모서리 값을 고릅니다. POSTECH Library의 `PobookUI`에서 쓰던 값과 이름을 유지해 `BeaverUI.ColorToken.primaryLight`, `BeaverUI.Spacing._16`처럼 사용할 수 있습니다.

`beaverTypography`는 글자 굵기와 크기, 글자 간격을 함께 적용하며 기기의 글자 크기 설정을 따릅니다. 앱에 Pretendard가 이미 등록되어 있으면 사용하고, 그 외에는 iOS 기본 글꼴로 표시합니다. 위치나 숫자를 좁은 지도 그림에 넣을 때는 `scaling: .fixed`로 크기를 고정할 수 있습니다.

```swift
import BeaverDesignSystem
import SwiftUI

struct VenueIntroduction: View {
    let onClose: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: BeaverUI.Spacing._16) {
            BeaverUI.DismissibleHeader(
                title: "전시장 안내",
                subtitle: "층별 시설을 둘러보세요.",
                onClose: onClose
            )
            Text("방문 전에 운영 시간을 확인해 주세요.")
                .beaverTypography(.body2)
            BeaverUI.UnderlinedButton("다음에 보기", action: onSkip)
        }
    }
}
```

`GlassIconButton`에는 버튼 이름과 SF Symbol을 넘깁니다. `HeaderBackground`는 지도 위의 제목 뒷부분을 흐리게 합니다. `ConfirmationCard`에는 안내 문구, 버튼 이름 두 개와 각 버튼을 눌렀을 때 할 일을 넘깁니다.

지도 표시, 마커 동작, 바텀시트와 디자인 시스템은 [POSTECH Library](https://github.com/adap-c6-fingerprint/postech-library/tree/c28a06e32434d0ccf8dccdc2a03ff1140757e379)의 구현을 기반으로 합니다.
