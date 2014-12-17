
var NewsList = React.createClass({
  render: function() {
    var unordered = this.props.unordered ? true : false;

    function renderItem(item) {
      return (
        <li data-foreach-item="items">
          <span className="label">{item.label}</span>
          <span className="value">{item.value}</span>
        </li>
      );
    }

    function renderList(items, unordered) {
      if (unordered) {
        return (<ol>{items.map(renderItem)}</ol>);
      } else {
        return (<ul className="list-nostyle">{items.map(renderItem)}</ul>);
      }
    }

    return (
      <div className="NewsList">
        <h1 className="title">{this.props.title}</h1>
        {renderList(this.props.items, unordered)}
        <p className="more-info">{this.props.moreinfo}</p>
        <p className="updated-at">{this.props.updatedAtMessage}</p>
      </div>
    );
  }
});
