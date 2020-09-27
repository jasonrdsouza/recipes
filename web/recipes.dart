import 'dart:html';
import 'package:markdown/markdown.dart';

void main() {
  print('Recipe loaded!');

  fetchElements('ingredient').forEach((e) => renderElementContentsAsHtml(e));
  fetchElements('step').forEach((e) => renderElementContentsAsHtml(e));
  fetchElements('note').forEach((e) => renderElementContentsAsHtml(e));
  fetchElements('based').forEach((e) => renderElementContentsAsHtml(e));
}

List<HtmlElement> fetchElements(String id) {
  return querySelectorAll('#${id}');
}

class PermissiveUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true;
  }
}

final NodeValidatorBuilder _validator = NodeValidatorBuilder.common()..allowNavigation(PermissiveUriPolicy());

void renderElementContentsAsHtml(HtmlElement element) {
  var renderedMarkdown = markdownToHtml(element.text);
  element.setInnerHtml(renderedMarkdown.substring(3, renderedMarkdown.length - 5), validator: _validator);
}
