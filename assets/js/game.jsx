import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container } from 'react-konva';
import useImage from 'use-image';
import spaceShipImg from '../static/images/spaceship.svg';

export default function game_init(root, channel) {
  ReactDOM.render(<Game/>, root);
}

const SpaceshipImage = (props) => {
  const [image] = useImage(spaceShipImg);
  return <Image {...{
    ...props,
    image: image,
    height: 50,
    width: 40}}/>
}

class Game extends React.Component {
  constructor(props)
  {
    super(props);
    const { channel } = this.props;
    this.state = {
      ship: {
        x: 500,//window.innerWidth/2,
        y: 500//(window.innerHeight - 60),
      }
    }
    this.channel = channel
    this.onKeyDown = this.onKeyDown.bind(this)
  }

  onKeyDown(e) {
    console.log(e.key)
    const { ship } = this.state
    const { key } = e;
    if(key == "ArrowLeft" || key == "a") {
        this.setState({ship: {...ship, x: ship.x - 5}});
      } else if(e.key == "ArrowRight" || key == "d") {
        this.setState({ship: {...ship, x: ship.x + 5}});
      }
    console.log(this.state.ship.x)
    }


  render() {
    const { ship: { x, y}} = this.state;
    console.log(x,y);
    return <div tabIndex="0" onKeyDown={(e) => {console.log(e); this.onKeyDown(e)}}>
      <Stage width={1000} height={700}>
      <Layer>
          <SpaceshipImage {...{x,y}}/>
      </Layer>
    </Stage>
  </div>
  }

}

