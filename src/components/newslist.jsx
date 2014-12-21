var React = require('react');

var NewsList = React.createClass({
  render: function() {
    function renderItem(item) {
      return (
        <li data-foreach-item="items">
          <span className="label">{item.label}</span>
          <span className="value">{item.value}</span>
        </li>
      );
    }

    var list;
    var items = this.props.items;
    var unordered = this.props.unordered ? true : false;

    if (unordered) {
      list = <ol>{items.map(renderItem)}</ol>;
    } else {
      list = <ul className="list-nostyle">{items.map(renderItem)}</ul>;
    }

    return (
      <div className="NewsList">
        <h1 className="title">{this.props.title}</h1>
        {list}
        <p className="more-info">{this.props.moreinfo}</p>
        <p className="updated-at">{this.props.updatedAtMessage}</p>
      </div>
    );
  }
});

module.exports = NewsList;
