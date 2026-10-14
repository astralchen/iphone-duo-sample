#if DEBUG
import UIKit

/// 为 Canvas 提供导航容器和局部 traits，不接管页面生命周期或系统数据。
enum PreviewSupport {
    enum Variant {
        case standard
        case regular
        case dark
        case accessibility
        case rightToLeft
    }

    static func page(
        _ content: UIViewController,
        title: String? = nil,
        variant: Variant = .standard
    ) -> UINavigationController {
        content.navigationItem.title = title
        let navigationController = UINavigationController(rootViewController: content)

        switch variant {
        case .standard:
            break
        case .regular:
            // 画布尺寸与 size class 分别配置，显式覆盖 traits 才能稳定进入 Regular 分支。
            navigationController.traitOverrides.horizontalSizeClass = .regular
            navigationController.traitOverrides.verticalSizeClass = .regular
        case .dark:
            navigationController.overrideUserInterfaceStyle = .dark
        case .accessibility:
            navigationController.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        case .rightToLeft:
            // 同时设置布局方向 trait 和视图语义方向，让导航栏与页面按 RTL 环境展示。
            navigationController.traitOverrides.layoutDirection = .rightToLeft
            navigationController.view.semanticContentAttribute = .forceRightToLeft
            navigationController.navigationBar.semanticContentAttribute = .forceRightToLeft
            content.view.semanticContentAttribute = .forceRightToLeft
        }

        return navigationController
    }

    /// 为独立图例提供背景和留白，避免 UIStackView 被拉伸至整个画布。
    static func component(_ content: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }
}
#endif
