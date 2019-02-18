import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container, Rect } from 'react-konva';
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
      /*
aliens: [
    %{health: 2, id: 0, posn: %{x: 10, y: 15}},
    %{health: 2, id: 1, posn: %{x: 20, y: 15}},
    %{health: 2, id: 2, posn: %{x: 30, y: 15}},
    %{health: 2, id: 3, posn: %{x: 40, y: 15}},
    %{health: 2, id: 4, posn: %{x: 50, y: 15}},
    %{health: 2, id: 5, posn: %{x: 10, y: 25}},
    %{health: 2, id: 6, posn: %{x: 20, y: 25}},
    %{health: 2, id: 7, posn: %{x: 30, y: 25}},
    %{health: 2, id: 8, posn: %{x: 40, y: 25}},
    %{health: 2, id: 9, posn: %{x: 50, y: 25}},
    %{health: 2, id: 10, posn: %{x: 10, y: 35}},
    %{health: 2, id: 11, posn: %{x: 20, y: 35}},
    %{health: 2, id: 12, posn: %{x: 30, y: 35}},
    %{health: 2, id: 13, posn: %{x: 40, y: 35}},
    %{health: 2, id: 14, posn: %{x: 50, y: 35}},
    %{health: 2, id: 15, posn: %{x: 10, y: 45}},
    %{health: 2, id: 16, posn: %{x: 20, y: 45}},
    %{health: 2, id: 17, posn: %{x: 30, y: 45}},
    %{health: 2, id: 18, posn: %{x: 40, y: 45}},
    %{health: 2, id: 19, posn: %{x: 50, y: 45}},
    %{health: 2, id: 20, posn: %{x: 10, y: 55}},
    %{health: 2, id: 21, posn: %{x: 20, y: 55}},
    %{health: 2, id: 22, posn: %{x: 30, y: 55}},
    %{health: 2, id: 23, posn: %{x: 40, y: 55}},
    %{health: 2, id: 24, posn: %{x: 50, y: 55}}
  ],
  barriers: [
    %{health: 10, id: 0, posn: %{x: 33, y: 220}},
    %{health: 10, id: 1, posn: %{x: 66, y: 220}},
    %{health: 10, id: 2, posn: %{x: 99, y: 220}}
  ],
  lasers: [
    %{id: 0, inplay: false, posn: %{x: 0, y: 0}},
    %{id: 1, inplay: false, posn: %{x: 0, y: 0}}
  ],
  players: [
    %{id: 0, lives: 3, posn: %{x: 25, y: 250}, powerups: 0},
    %{id: 1, lives: 3, posn: %{x: 50, y: 250}, powerups: 0}
  ],
  right_shift: false

*/

      barriers: [
        {
          posn: {
            x: 33,
            y: 220,
          }
        },
        {
          posn: {
            x: 66,
            y: 220,
          }
        },
        {
          posn: {
            x: 99,
            y: 220,
          }
        },
      ],
      aliens: [
        {
          posn: {
            x: 10,
            y: 15
          },
        },
        {
          posn: {
            x: 20,
            y: 15
          },
        },
        {
          posn: {
            x: 30,
            y: 15
          },
        },
        {
          posn: {
            x: 40,
            y: 15
          },
        },
        {
          posn: {
            x: 50,
            y: 15
          },
        }

      ],
      players: [
        {
          posn:
          {
            x: 25,//window.innerWidth/2,
            y: 250//(window.innerHeight - 60),
          },
        },
        {
          posn:
          {
            x: 50,//window.innerWidth/2,
            y: 250//(window.innerHeight - 60),
          },
        },

      ],
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
    aliens.forEach((alien) => {
      out.push(<AlienImage {...{x: (alien.posn.x * 10) + 40, y: alien.posn.y * 4}}/>);
    })
    return out;
  }


  renderBarriers(barriers){
    const out = [];
    barriers.forEach((barrier) => {
      out.push(<Rect {...{
        x: (barrier.posn.x * 6) - 30,
        y: barrier.posn.y * 3,
        height: 20,
        width: 60,
        fill: 'black'}}/>)
    })
    return out;
  }

  renderPlayers(players) {
    const out = [];
    players.forEach((player) =>
      out.push(<SpaceshipImage {...{x: (player.posn.x * 10) + 40, y: player.posn.y * 3}}/>));
    return out
  }

  render() {
    const { players, aliens, barriers} = this.state;
    const alienComponents = this.renderAliens(aliens);
    const playerComponents = this.renderPlayers(players);
    const barrierComponents = this.renderBarriers(barriers);
    console.log(barrierComponents)
    return <div tabIndex="0" onKeyDown={(e) => {console.log(e); this.onKeyDown(e)}}>
      <Stage width={750} height={1000}>
        <Layer>
          {playerComponents}
          {alienComponents}
          {barrierComponents}
        </Layer>
      </Stage>
    </div>
  }

}

