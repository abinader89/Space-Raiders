import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container } from 'react-konva';
import useImage from 'use-image';
import spaceShipImg from '../static/images/spaceship.svg';
import alienImage from '../static/images/enemy1.svg';

export default function game_init(root, channel) {
  ReactDOM.render(<Game/>, root);
}

const SpaceshipImage = (props) => {
  const [image] = useImage(spaceShipImg);
  return <Image {...{
    ...props,
    image: image,
    height: 50,
    width: 40,
    }}/>
}

const AlienImage = (props) => {
  const [image] = useImage(alienImage)
  return <Image {...{
    ...props,
    image: image,
    height: 50,
    width: 40,
    rotation: 180}}/>
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
      },
      aliens: new Array(30)
    }
    this.channel = channel
    this.onKeyDown = this.onKeyDown.bind(this)
  }

  onKeyDown(e) {
    const { ship } = this.state
    const { key } = e;
    if(key == "ArrowLeft" || key == "a") {
        this.setState({ship: {...ship, x: ship.x - 5}});
      } else if(e.key == "ArrowRight" || key == "d") {
        this.setState({ship: {...ship, x: ship.x + 5}});
      }
    }

  renderAliens(aliens){
    const out = [];
    console.log(aliens.length)
    for(let i = 0; i < aliens.length; i++){
      const x = (i * 100) % 1000;
      const y = (Math.floor(i/10) * 100) + 100;
      console.log(x,y)
      out.push(<AlienImage {...{x,y}}/>)
    }
    return out;
  }
  render() {
    const { ship: { x, y}, aliens} = this.state;
    const alienComponents = this.renderAliens(aliens);
    console.log(x,y);
    return <div tabIndex="0" onKeyDown={(e) => {console.log(e); this.onKeyDown(e)}}>
      <Stage width={1000} height={700}>
      <Layer>
        <SpaceshipImage {...{x,y}}/>
        {alienComponents}
      </Layer>
    </Stage>
  </div>
  }

}

