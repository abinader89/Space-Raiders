import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

export default function game_init(root, channel) {
  ReactDOM.render(<Game/>, root);
}

class Game extends React.Component {
  constructor(props)
  {
    super(props);
    const { channel } = this.props;
    this.channel = channel
  }



  render() {
     return <div>
      <a>React works</a>
    </div>
  }

}

