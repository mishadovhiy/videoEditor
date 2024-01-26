project state: not completed

## Technical overview of current features
- Combine videos with AVMutableComposition 
- add CaLayer to AVAsset with animation with CABasicAnimation


# Auto scroll assets when video is playing
https://github.com/mishadovhiy/videoEditor/assets/44978117/5879c05a-5ada-4658-89ba-ebf832989ce7

### UILabels sticks to the corners of the screen, and stays inside it's superview, by adding the next constraints:
UILabels have constant greaterThanOrEqualTo the first UIView of UIViewController (leadingAnchor) 
and .left and .right constants to UILabel's superview
see in the file: https://github.com/mishadovhiy/videoEditor/blob/main/VideoEditorUIkit/NSObject/UIView/AssetAttachmentView/AssetRawView.swift#L53




# Manual scroll - performs seek in the AVAsset
https://github.com/mishadovhiy/videoEditor/assets/44978117/d41d54e6-267f-4e2a-a81f-2cd2d97d90ae

