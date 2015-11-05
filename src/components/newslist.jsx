import React, {Component} from 'react';

const NewsList = (props) => {
  const renderItem = (item) => (
      <li key={item.link}>
        <span className="label">{item.label}</span>
        <span className="value">{item.value}</span>
      </li>
  );

  let list;
  let items = props.items;
  let unordered = props.unordered ? true : false;

  if (unordered) {
    list = <ol>{items.map(renderItem)}</ol>;
  } else {
    list = <ul className="list-nostyle">{items.map(renderItem)}</ul>;
  }

  return (
      <div className="NewsList">
        <h1 className="title">{props.title}</h1>
        {list}
        <p className="more-info">{props.moreinfo}</p>
        <p className="updated-at">{props.updatedAtMessage}</p>
      </div>
  );
};

export default NewsList;
