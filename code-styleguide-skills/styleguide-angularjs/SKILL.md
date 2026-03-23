<!--
UpdatedAt: 2026-03-23 16:32:59
LatestChange: 质量精修：统一参考链接格式并去重，补充本地/CI工程命令清单，更新矩阵关联一致性。
-->

# AngularJS Code Style Skill

## 目标

基于 Google AngularJS Style Guide（Closure 场景），为 AngularJS（1.x）代码提供可执行的风格约束，用于：

- Code Review：快速识别模块组织、依赖注入、控制器/指令/服务设计中的风格问题。
- 风格统一：在不改变业务语义的前提下减少“写法漂移”。
- 输出建议：将规范落为“检查点 + 最小示例”，避免背诵式长文。

## 规范来源与优先级

1. 项目/团队约定（若项目已有强制 lint/构建规则，以其为准）。
2. 本 AngularJS skill（本文）。
3. Google AngularJS Style Guide（官方原文）。
4. Google JavaScript Style Guide（AngularJS 未覆盖处的补充）。

当冲突或无法确定时，默认选择：更可读、更一致、更接近现有代码库风格的一侧，并说明理由。

## 核心检查清单（可执行）

### 依赖与模块（Dependencies / modules）

- **Closure 依赖管理**：使用 `goog.provide` 和 `goog.require` 管理命名空间依赖。
- **模块定义归属稳定**：模块只在定义处创建，不在其他文件“二次改写”。
- **主模块位置清晰**：应用主模块放在 root client 目录，便于发现与装配。
- **模块依赖引用 `.name`**：依赖子模块时使用 `subModule.name`，不要重复写字符串字面量模块名。

### 控制器与作用域（Controllers / scope）

- **控制器是类**：将行为定义在 `MyCtrl.prototype`，避免把大量函数塞进 `$scope`。
- **优先 controller-as**：模板中使用 `ng-controller="MyCtrl as myCtrl"`，统一通过 `myCtrl.xxx` 访问。
- **属性归属清晰**：控制器状态放在 `this` 上，避免随意向 `$scope` 扩散业务字段。
- **注入声明可编译**：构造函数参数可被压缩安全识别（如 `@ngInject` 流程）。

### 指令（Directives）

- **DOM 操作仅在指令中**：页面 DOM 操作放进 directive，避免控制器/服务直接操作页面节点。
- **指令保持小而可组合**：一个指令只做一类职责，优先组合而非“巨型指令”。
- **导出工厂函数**：定义 directive 的文件导出返回 Directive Definition Object 的静态函数。
- **例外场景明确**：仅对脱离常规视图树的 DOM（如对话框/全局快捷键）可在服务中操作。

### 服务（Services）

- **默认使用 `module.service`**：服务按“类实例”组织；除非确有初始化需求，否则不优先 `factory/provider`。
- **服务内部状态封装**：依赖放在实例字段中（如 `this.http_`），减少外部可变状态泄漏。

### 命名与约定（Naming conventions）

- **保留 `$` 给 Angular/jQuery 内建**：自定义属性、服务名、字段名不要以前缀 `$` 命名。
- **区分框架对象与业务对象**：注入参数可使用 `$http` 等内建名，自定义对象保持普通命名。

### 构建与类型约束（Build / typing）

- **面向可编译产物**：面向用户的代码应走编译流程，不依赖“开发态偶然可运行”。
- **属性重命名场景需可导出**：模板/外部反射访问到的控制器成员需遵循导出注解策略（如 `@export`）。
- **统一 externs 策略**：对外部类型依赖集中管理 externs，避免压缩后行为不一致。

### 测试与可维护性（Testing / maintainability）

- **优先可测试结构**：控制器/服务逻辑保持纯净边界，利于单测隔离。
- **Angular 测试基建一致**：团队统一测试基建（如 Jasmine + Karma）与模块注入方式。

## 最小示例

### 模块依赖写法

```js
// Yes
goog.require('my.submoduleA');
my.app.module = angular.module('my.app', [my.submoduleA.name]);

// No
my.app.module = angular.module('my.app', ['my.submoduleA']);
```

### controller-as 写法

```html
<!-- Yes -->
<div ng-controller="hello.mainpage.HomeCtrl as homeCtrl">
  <span>{{homeCtrl.add(5, 6)}}</span>
</div>
```

```js
// Yes: 属性与方法定义在控制器实例/原型上
hello.mainpage.HomeCtrl = function() {
  this.myColor = 'blue';
};
hello.mainpage.HomeCtrl.prototype.add = function(a, b) {
  return a + b;
};
```

### `$` 命名约束

```js
// Yes
myModule.service('myService', function() {});
var MyCtrl = function($http) { this.http_ = $http; };

// No
myModule.service('$myService', function() {});
var MyCtrl = function($http) { this.$http_ = $http; };
```


## 工程化落地（Workflow）

- **本地一致性**：提交前至少执行格式化与静态检查，避免仅在 CI 暴露风格问题。
- **CI 守门**：将风格检查作为必过项；格式化工具输出与审查结论冲突时，以团队约定优先并在 PR 说明。
- **渐进整改**：遗留代码按“触达即治理”原则处理，优先修复当前变更范围内的风格/可读性问题。

## 常见冲突与处置

- **规范冲突**：优先级始终为“项目约定 > 本文 > 官方参考”。
- **工具与人工结论冲突**：优先保证可读性与一致性，并在评审中记录取舍理由。
- **增量与全量冲突**：优先保证本次修改范围一致，避免在无关区域引入大规模格式噪音。

## 工程化命令（本地/CI）

- 本地：`eslint . --fix`
- CI：`eslint . && karma start --single-run`（按项目测试栈调整）

## 本 skill 的回答方式（输出模板）

当用户给出 AngularJS 代码/文件路径/问题描述时，按以下结构输出：

1. **适用范围判定**：AngularJS + 涉及点（模块依赖、controller-as、指令、服务、命名、构建）。
2. **结论（3-10 条检查点）**：优先指出高风险问题（模块字符串硬编码、控制器污染 `$scope`、非指令 DOM 操作、`$` 命名误用）。
3. **最小示例**：只给必要的 before/after 或正确/错误对照。
4. **不改变语义声明**：强调默认只做风格层改动，除非用户明确要求语义重构。

## 参考

- [Google AngularJS Style Guide（官方）](https://google.github.io/styleguide/angularjs-google-style.html)
- [Google JavaScript Style Guide（补充）](https://google.github.io/styleguide/jsguide.html)
- [Google Style Guides（索引）](https://google.github.io/styleguide/)
