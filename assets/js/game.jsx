import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image } from 'react-konva';
import useImage from 'use-image';
import spaceShipImg from '../static/images/spaceship.svg';

export default function game_init(root, channel) {
  ReactDOM.render(<Game/>, root);
}

const SpaceshipImage = () => {
  const [image] = useImage(spaceShipImg);
  return <Image image={image} x={0} y={0}/>
}

class Game extends React.Component {
  constructor(props)
  {
    super(props);
    const { channel } = this.props;
    this.state = {
    

    }
    this.channel = channel
  }

  render() {
    return <Stage width={window.innerWidth} height={window.innerHeight}>
      <Layer>
        <SpaceshipImage/>
      </Layer>
    </Stage>
  }

}

